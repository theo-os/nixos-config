use anyhow::{Context, Result};
use clap::{Parser, Subcommand};
use crossterm::{
    event::{self, Event, KeyCode, KeyEvent},
    execute,
    terminal::{disable_raw_mode, enable_raw_mode, EnterAlternateScreen, LeaveAlternateScreen},
};
use petgraph::{
    graph::{DiGraph, NodeIndex},
    visit::EdgeRef,
    Direction,
};
use ratatui::{
    backend::CrosstermBackend,
    layout::{Constraint, Layout},
    style::{Color, Modifier, Style},
    text::{Line, Span},
    widgets::{Block, Borders, List, ListItem, Paragraph},
    Terminal,
};
use std::collections::HashMap;
use std::io;
use std::path::PathBuf;
use std::process::Command;

#[derive(Parser)]
#[command(name = "nix-tree")]
#[command(about = "Visualize Nix store dependencies", long_about = None)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    /// Show interactive TUI tree view
    Show {
        /// Store path to visualize
        #[arg(value_name = "PATH")]
        path: String,
    },
    /// Export dependency graph as SVG
    Svg {
        /// Store path to visualize
        #[arg(value_name = "PATH")]
        path: String,
        /// Output SVG file path
        #[arg(short, long, default_value = "output.svg")]
        output: PathBuf,
    },
}

struct App {
    graph: DiGraph<String, ()>,
    root_node: NodeIndex,
    selected: usize,
    items: Vec<(String, usize)>, // (path, depth)
    scroll_offset: usize,
}

impl App {
    fn new(store_path: &str) -> Result<Self> {
        let mut graph = DiGraph::new();
        let mut node_map = HashMap::new();
        
        // Add root node
        let root_node = graph.add_node(store_path.to_string());
        node_map.insert(store_path.to_string(), root_node);
        
        // Build dependency graph using nix-store if available
        if let Ok(deps) = Self::query_dependencies(store_path) {
            for dep in deps {
                let dep_node = *node_map.entry(dep.clone()).or_insert_with(|| graph.add_node(dep));
                graph.add_edge(root_node, dep_node, ());
            }
        }
        
        // Build flat list for display
        let items = Self::build_items(&graph, root_node);
        
        Ok(App {
            graph,
            root_node,
            selected: 0,
            items,
            scroll_offset: 0,
        })
    }

    fn query_dependencies(path: &str) -> Result<Vec<String>> {
        // Try to query dependencies using nix-store
        let output = Command::new("nix-store")
            .args(["--query", "--references", path])
            .output();
        
        match output {
            Ok(out) if out.status.success() => {
                let deps = String::from_utf8_lossy(&out.stdout)
                    .lines()
                    .filter(|line| !line.is_empty() && line != &path)
                    .map(|s| s.to_string())
                    .collect();
                Ok(deps)
            }
            _ => Ok(Vec::new()),
        }
    }

    fn build_items(graph: &DiGraph<String, ()>, node: NodeIndex) -> Vec<(String, usize)> {
        let mut items = Vec::new();
        let mut visited = std::collections::HashSet::new();
        Self::traverse(graph, node, 0, &mut items, &mut visited);
        items
    }

    fn traverse(
        graph: &DiGraph<String, ()>,
        node: NodeIndex,
        depth: usize,
        items: &mut Vec<(String, usize)>,
        visited: &mut std::collections::HashSet<NodeIndex>,
    ) {
        if visited.contains(&node) {
            return;
        }
        visited.insert(node);
        
        let path = &graph[node];
        items.push((path.clone(), depth));
        
        for edge in graph.edges_directed(node, Direction::Outgoing) {
            Self::traverse(graph, edge.target(), depth + 1, items, visited);
        }
    }

    fn render(&self, terminal: &mut Terminal<CrosstermBackend<io::Stdout>>) -> Result<()> {
        terminal.draw(|f| {
            let chunks = Layout::default()
                .constraints([Constraint::Percentage(80), Constraint::Percentage(20)].as_ref())
                .split(f.area());

            let visible_height = chunks[0].height as usize - 2; // Account for borders
            let start = self.scroll_offset;
            let end = (start + visible_height).min(self.items.len());

            // Create list items with indentation based on depth
            let list_items: Vec<ListItem> = self
                .items
                .iter()
                .enumerate()
                .skip(start)
                .take(end - start)
                .map(|(idx, (path, depth))| {
                    let indent = "  ".repeat(*depth);
                    let style = if idx == self.selected {
                        Style::default().fg(Color::Yellow).add_modifier(Modifier::BOLD)
                    } else {
                        Style::default()
                    };
                    
                    // Shorten path for display
                    let display_path = if path.len() > 80 {
                        format!("...{}", &path[path.len() - 77..])
                    } else {
                        path.clone()
                    };
                    
                    let content = format!("{}{}", indent, display_path);
                    ListItem::new(Line::from(Span::styled(content, style)))
                })
                .collect();

            let title = format!("Nix Store Dependencies ({} items)", self.items.len());
            let list = List::new(list_items).block(
                Block::default()
                    .title(title)
                    .borders(Borders::ALL),
            );

            f.render_widget(list, chunks[0]);

            let help_text = Paragraph::new(vec![
                Line::from("Controls:"),
                Line::from("↑/k - Move up"),
                Line::from("↓/j - Move down"),
                Line::from("q - Quit"),
            ])
            .block(Block::default().title("Help").borders(Borders::ALL));

            f.render_widget(help_text, chunks[1]);
        })?;

        Ok(())
    }

    fn move_up(&mut self) {
        if self.selected > 0 {
            self.selected -= 1;
            if self.selected < self.scroll_offset {
                self.scroll_offset = self.selected;
            }
        }
    }

    fn move_down(&mut self) {
        if self.selected < self.items.len().saturating_sub(1) {
            self.selected += 1;
            // Assume a reasonable viewport height
            let viewport_height = 20;
            if self.selected >= self.scroll_offset + viewport_height {
                self.scroll_offset = self.selected - viewport_height + 1;
            }
        }
    }
}

fn run_tui(store_path: &str) -> Result<()> {
    // Setup terminal
    enable_raw_mode()?;
    let mut stdout = io::stdout();
    execute!(stdout, EnterAlternateScreen)?;
    let backend = CrosstermBackend::new(stdout);
    let mut terminal = Terminal::new(backend)?;

    // Create app
    let mut app = App::new(store_path)?;

    // Run event loop
    loop {
        app.render(&mut terminal)?;

        if let Event::Key(KeyEvent { code, .. }) = event::read()? {
            match code {
                KeyCode::Char('q') => break,
                KeyCode::Up | KeyCode::Char('k') => app.move_up(),
                KeyCode::Down | KeyCode::Char('j') => app.move_down(),
                _ => {}
            }
        }
    }

    // Restore terminal
    disable_raw_mode()?;
    execute!(terminal.backend_mut(), LeaveAlternateScreen)?;

    Ok(())
}

fn generate_svg(store_path: &str, output: &PathBuf) -> Result<()> {
    let mut graph = DiGraph::new();
    let mut node_map = HashMap::new();
    
    // Add root node
    let root_node = graph.add_node(store_path.to_string());
    node_map.insert(store_path.to_string(), root_node);
    
    // Try to query dependencies
    if let Ok(deps) = App::query_dependencies(store_path) {
        for dep in deps {
            let dep_node = *node_map.entry(dep.clone()).or_insert_with(|| graph.add_node(dep));
            graph.add_edge(root_node, dep_node, ());
        }
    }
    
    // Create SVG document
    let width = 800;
    let height = 600;
    let mut document = svg::Document::new().set("viewBox", (0, 0, width, height));
    
    // Add background
    let rect = svg::node::element::Rectangle::new()
        .set("x", 0)
        .set("y", 0)
        .set("width", width)
        .set("height", height)
        .set("fill", "#f9f9f9");
    
    document = document.add(rect);
    
    // Layout nodes in a simple tree structure
    let node_count = graph.node_count();
    let center_x = width / 2;
    let y_spacing = if node_count > 1 { height / (node_count + 1) } else { height / 2 };
    
    // Draw edges first (so they appear behind nodes)
    for edge in graph.edge_references() {
        let source_idx = edge.source().index();
        let target_idx = edge.target().index();
        
        let x1 = center_x;
        let y1 = y_spacing * (source_idx + 1);
        let x2 = center_x;
        let y2 = y_spacing * (target_idx + 1);
        
        let line = svg::node::element::Line::new()
            .set("x1", x1)
            .set("y1", y1)
            .set("x2", x2)
            .set("y2", y2)
            .set("stroke", "#999")
            .set("stroke-width", 2);
        
        document = document.add(line);
    }
    
    // Draw nodes
    for (idx, node_idx) in graph.node_indices().enumerate() {
        let path = &graph[node_idx];
        let x = center_x;
        let y = y_spacing * (idx + 1);
        
        // Draw node circle
        let circle = svg::node::element::Circle::new()
            .set("cx", x)
            .set("cy", y)
            .set("r", 8)
            .set("fill", if idx == 0 { "#4CAF50" } else { "#2196F3" })
            .set("stroke", "white")
            .set("stroke-width", 2);
        
        document = document.add(circle);
        
        // Draw node label (shortened path)
        let label = if path.len() > 50 {
            format!("...{}", &path[path.len() - 47..])
        } else {
            path.clone()
        };
        
        let text = svg::node::element::Text::new(label)
            .set("x", x + 15)
            .set("y", y + 5)
            .set("font-size", 10)
            .set("font-family", "monospace");
        
        document = document.add(text);
    }
    
    // Write to file
    svg::save(output, &document).context("Failed to save SVG")?;
    println!("SVG saved to {} ({} nodes)", output.display(), node_count);
    
    Ok(())
}

fn main() -> Result<()> {
    let cli = Cli::parse();

    match cli.command {
        Commands::Show { path } => {
            run_tui(&path)?;
        }
        Commands::Svg { path, output } => {
            generate_svg(&path, &output)?;
        }
    }

    Ok(())
}

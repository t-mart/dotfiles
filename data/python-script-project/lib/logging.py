from rich import box
from rich.console import Console
from rich.panel import Panel
from rich.prompt import Prompt
from rich.text import Text

__all__ = [
    "console",
    "log_info",
    "log_error",
    "log_phase",
    "log_step",
    "log_panel",
    "prompt_continue",
]

console = Console()


def log_phase(msg: str) -> None:
    console.print()
    console.print(
        Panel(
            Text(msg.upper(), justify="center", style="bold bright_white"),
            box=box.DOUBLE,
            border_style="bright_cyan",
        )
    )
    console.print()


def log_info(msg: str) -> None:
    console.print(f"[cyan]•[/cyan] {msg}")


def log_error(msg: str) -> None:
    console.print(f"[bold red]✗[/bold red] {msg}")


def log_step(msg: str) -> None:
    console.rule(f"[bold magenta]{msg}[/bold magenta]")


def log_panel(body: str, title: str) -> None:
    console.print(Panel(body, title=title))


def prompt_continue(msg: str = "Press Enter to continue") -> None:
    Prompt.ask(msg, default="")

from rich import box
from rich.console import Console
from rich.panel import Panel
from rich.prompt import Confirm
from rich.align import Align
from rich.text import Text

__all__ = [
    "console",
    "log_info",
    "log_error",
    "log_phase_start",
    "log_phase_end",
    "log_step",
    "log_panel",
    "prompt_confirm",
]

console = Console(width=80, tab_size=4)


def log_phase_start(msg: str) -> None:
    console.rule(f"[bold cyan]{msg}[/bold cyan]", characters="=")


def log_phase_end(msg: str) -> None:
    console.rule(f"[bold cyan]{msg} complete[/bold cyan]", characters="=")


def log_info(msg: str) -> None:
    console.print(msg)


def log_error(msg: str) -> None:
    console.print(f"[bold red]✗[/bold red] {msg}")


def log_step(msg: str) -> None:
    console.rule(f"[bold magenta]{msg}[/bold magenta]")


def log_panel(body: str, title: str) -> None:
    console.print(Panel(body, title=title))


def prompt_confirm(msg: str, *, default: bool = False) -> bool:
    return Confirm.ask(msg, default=default, console=console)

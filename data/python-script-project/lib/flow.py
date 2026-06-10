import functools
from collections.abc import Callable, Iterator
from contextlib import contextmanager
from typing import ParamSpec, TypeVar

from lib.arch_linux import is_arch_linux
from lib.logging import log_phase, log_step

P = ParamSpec("P")
R = TypeVar("R")

__all__ = ["phase", "step"]


@contextmanager
def phase(name: str) -> Iterator[None]:
    """A top-level chezmoi phase (before/after apply). Logs, for now."""
    log_phase(name)
    yield


def step(
    name: str, *, arch_only: bool = False
) -> Callable[[Callable[P, R]], Callable[P, R | None]]:
    """Decorator marking a step within a phase: log the step, then run it.

    If `arch_only` is set, the step is skipped silently — not even logged — on
    non-Arch systems.
    """

    def decorator(func: Callable[P, R]) -> Callable[P, R | None]:
        @functools.wraps(func)
        def wrapper(*args: P.args, **kwargs: P.kwargs) -> R | None:
            if arch_only and not is_arch_linux():
                return None
            log_step(name)
            return func(*args, **kwargs)

        return wrapper

    return decorator

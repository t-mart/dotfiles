{ pkgs, ... }:
{
  home.packages = with pkgs; [
    atomicparsley
    bun
    claude-code
    codex
    deno
    ffmpeg
    gallery-dl
    gh
    go
    hyperfine
    imagemagick
    jwt-cli
    lazygit
    magic-wormhole
    nodejs
    opentofu
    pnpm
    rustup
    yt-dlp
  ];
}

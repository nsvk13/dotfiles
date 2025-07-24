# My Dotfiles 🚀

Quick development environment setup with Zsh, Powerlevel10k, enhanced Nano, and useful aliases.

## What's Included

- **Zsh** with Oh My Zsh and Powerlevel10k theme
- **Nano** with syntax highlighting and convenient settings
- **Plugins**: zsh-autosuggestions, zsh-syntax-highlighting
- **Aliases**: useful shortcuts for git, docker, kubectl

## Quick Install

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Run auto-installer
chmod +x install.sh
./install.sh
```

## Configuration Files

- `configs/.zshrc` - Zsh configuration
- `configs/.nanorc` - Nano settings
- `install.sh` - installation script

## After Installation

1. Restart your terminal or run `exec zsh`
2. Run `p10k configure` to customize Powerlevel10k theme (if needed)

## Useful Aliases

### Git
- `g` = `git`
- `gs` = `git status`
- `ga` = `git add`
- `gc` = `git commit`
- `gp` = `git push`
- `gl` = `git pull`

### Docker
- `d` = `docker`
- `dc` = `docker-compose`
- `dps` = `docker ps`

### Kubernetes
- `k` = `kubectl`
- `kg` = `kubectl get`
- `kd` = `kubectl describe`

### System
- `ll` = `ls -alF`
- `..` = `cd ..`
- `...` = `cd ../..`
- `update` = `sudo apt update && sudo apt upgrade`
- `reload` = `source ~/.zshrc`

## Repository Structure

```
dotfiles/
├── configs/
│   ├── .zshrc      # Zsh configuration
│   └── .nanorc     # Nano settings
├── install.sh      # Installation script
└── README.md       # This instruction
```

## Updating

To update configuration:

```bash
cd ~/.dotfiles
git pull
./install.sh
```

## Customization

Add your custom settings to `~/.zshrc.local` - it will be automatically loaded if exists.

## What the installer does

1. Detects OS (Ubuntu/CentOS/Alpine/macOS)
2. Installs dependencies (git, curl, zsh, nano)
3. Installs Oh My Zsh
4. Installs Powerlevel10k theme (both methods)
5. Installs zsh plugins (autosuggestions, syntax-highlighting)
6. Sets up nano with enhanced syntax highlighting
7. Copies your configs (with backup of existing ones)
8. Sets zsh as default shell

---

**Compatibility**: Ubuntu, Debian, CentOS, Alpine Linux, macOS
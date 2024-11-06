# Diagram Editor

![payload](https://raw.github.com/elizarim/diagram_editor/main/.screenshots/diagram_editor.png)

## Client Install Guide

1. Open Terminal.
2. Go to ~/Downloads folder: `cd ~/Download`.
3. Download archive with application inside: `curl -LO https://github.com/elizarim/diagram_editor/releases/download/release-1.0.0/DiagramEditor-1.0.0.zip`.
4. Unzip application: `unzip DiagramEditor-1.0.0.zip`.
5. Move application to Application folder: `mv DiagramEditor.app ~/Applications`
6. Remove quarantine attributes: `xattr -rd com.apple.quarantine ~/Applications/DiagramEditor.app`.
7. Run DiagramEditor

## Backend Install Guide

1. Download and install Docker Desktop application from https://www.docker.com/
2. Clone this repository: `git clone https://github.com/elizarim/diagram_editor.git`
3. Go to backend folder inside repository: `cd diagram_editor/backend`
4. Build backend image: `docker-compose build`
5. Run backend: `docker-compose up`
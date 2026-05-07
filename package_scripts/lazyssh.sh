curl -L https://github.com/Adembc/lazyssh/releases/download/v0.3.0/lazyssh_Linux_x86_64.tar.gz -o /tmp/lazyssh.tar.gz
mkdir -p ~/.local/bin
tar -xzf /tmp/lazyssh.tar.gz -C ~/.local/bin/ lazyssh
rm /tmp/lazyssh.tar.gz

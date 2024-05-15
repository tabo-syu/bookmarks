# Bookmarks

## Local Development

1. Install [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
2. Open as Dev Container

```console
$ nvm install --lts

$ bundle install

// Edit credentials
$ EDITOR="code --wait" bin/rails credentials:edit
# aws:
#   access_key_id: 123
#   secret_access_key: 345
discord:
  token: xxxxx
  channel_id: xxxxx

# Used as the base secret for all MessageVerifiers in Rails, including the one protecting cookies.
secret_key_base: xxxxx

// Run development server
$ rails s
```

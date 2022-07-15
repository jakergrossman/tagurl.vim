# tagurl.vim
Copy the URL for a help tag on [vimhelp.org](https://www.vimhelp.org) or [neovim.io](https://neovim.io/doc/user/)
to the clipboard

## Overview
I created this simple plugin because I was posting a lot on the Vi and Vim Stack
Exchange, and was frequently using links to vimhelp.org. I wanted a more
convenient way to get those links. Previously, I had been using the search
function on the site itself, even though I almost always had the help window
open for Vim anyway.

It's usage primarily revolves around the `:TagURL` command and a corresponding
mapping

### The `:TagURL` command
The `:TagURL` command takes a tag and an optional output register.

It will attempt to open the help page for the passed tag, and if successful,
will generate a URL based on the help file and tag for vimhelp.org.

It will then copy the generated URL to either the specified register or the
value of `g:tagurl_default_reg`.

### The TagURL Mapping
By default, tagurl.vim creates a normal mode mapping on `<C-k>` to call
`:TagURL` with the value of the word under the cursor. This can be disabled by
setting `g:tagurl_enable_mapping = v:false` in your `.vimrc`, and the key
sequence to map to can be edited by setting `g:tagurl_map` to the desired
mapping.

## Options

- `g:tagurl_map`            - The normal mode mapping to use for tagurl.vim
- `g:tagurl_enable_mapping` - Whether or not to set the `:TagURL`  mapping
- `g:tagurl_default_reg`    - The register to copy to if none is specified
- `g:tagurl_verbose`        - Whether or not `:TagURL` will echo status messages.
- `g:tagurl_neovim`         - Whether to use `neovim.io` instead of `vimhelp.org`.
                              This is required when linking NeoVim specific help documents,
                              e.g.: LSP

---

## Behind the Scenes
The help tag URL for vimhelp.org is structured as follows:

    https://vimhelp.org/<helpfile>.html#<tag>

where `<helpfile>` is the name of the help file the tag is in (options.txt,
movement.txt, etc.), and `<tag>` is the tag itself escaped for use in a URL.
The format for neovim.io is similar.

tagurl.vim also exposes a `tagurl#tagurl(tag,...)` function, which actually performs
the work for `:TagURL` in Command-line mode. It takes the same arguments as
`:TagURL`, a required tag and an optional output register.

So, `tagurl#tagurl(tag,...)` tries to open the help file specified by `a:tag`.
If an error is not caught, it knows it must have found *some* tag, and will then
use the current file and tag to build the URL. If any additional arguments were
passed, the first is treated as a register name to save to. Otherwise, it will
save to the register specified by `g:tagurl_default_reg`.

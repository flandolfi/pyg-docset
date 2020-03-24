SPHINXBUILD   = sphinx-build
SPHINXPROJ    = pytorch_geometric
SOURCEDIR     = pytorch_geometric/docs/source
BUILDDIR      = build

DISPLAYNAME   = "PyTorch-Geometric"
ICONNAME      = _static/img/icon.png
SVGPROC       = inkscape
SVGOPTS       = -e
DASHBUILD     = doc2dash
DOCSETDIR	  = $(DISPLAYNAME).docset
PLISTPATH     = $(DOCSETDIR)/Contents/Info.plist

VERSIONCMD    = cd $(SPHINXPROJ) && git describe --tags
VERSION       := $(shell $(VERSIONCMD))
BASEURL       = "https://github.com/flandolfi/pyg-docset/releases/download/$(VERSION)/"
ENCODEDURL    := $(shell echo $(BASEURL) | sed 's/\//%2F/g; s/:/%3A/g')

XMLTEXT		  = "<entry>" \
		"<version>$(VERSION)</version>" \
		"<url>$(BASEURL)$(DISPLAYNAME).tgz</url>" \
	"</entry>"

README        = README.md
READMETXT     = "\# PyTorch Geometric Docset \#\n\n"\
	"Use one of the following links to add the [PyTorch Geometric](https://pytorch-geometric.readthedocs.io/en/latest/) docset:\n\n"\
	" - **On Dash:** Just go to [\`dash-feed://$(ENCODEDURL)$(DISPLAYNAME).xml\`](dash-feed://$(ENCODEDURL)$(DISPLAYNAME).xml)\n"\
	" - **On Zeal:** Copy this link [\`$(BASEURL)$(DISPLAYNAME).xml\`]($(BASEURL)$(DISPLAYNAME).xml) and paste it on *Tools → Docsets... → Add Feed*.\n"

.PHONY: docset update clean all readme xml tgz


all: update docset tgz xml readme

update:
	@git submodule foreach git pull
	@VERSION=`$(VERSIONCMD)`

clean:
	-rm -R $(DOCSETDIR) 
	-rm -R $(BUILDDIR)

readme $(README):
	@echo $(READMETXT) > $(README)

xml $(DISPLAYNAME).xml:
	@echo $(XMLTEXT) > $(BUILDDIR)/$(DISPLAYNAME).xml

tgz $(DISPLAYNAME).tgz:
	@tar --exclude='.DS_Store' -cvzf $(BUILDDIR)/$(DISPLAYNAME).tgz $(DOCSETDIR)

docset $(DOCSETDIR) $(BUILDDIR):
	@$(SPHINXBUILD) -D html_static_path="../../../_static", "$(SOURCEDIR)" "$(BUILDDIR)"
	@$(DASHBUILD) -f -n $(DISPLAYNAME) -i $(ICONNAME) $(BUILDDIR) 
	@sed -i -e '/<key>DocSetPlatformFamily<\/key>/!b;n;c\\t<string>pyg<\/string>' $(PLISTPATH)
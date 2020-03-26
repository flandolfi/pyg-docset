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
BASEURL       = "https://github.com/flandolfi/pyg-docset/raw/master/$(BUILDDIR)/"
ENCODEDURL    := $(shell echo $(BASEURL) | sed 's/\//%2F/g; s/:/%3A/g')

XMLTEXT		  = "<entry>" \
		"<version>$(VERSION)</version>" \
		"<url>$(BASEURL)$(DISPLAYNAME).tgz</url>" \
	"</entry>"

.PHONY: docset update clean all xml tgz


all: update docset tgz xml

update:
	@git submodule foreach git pull
	@VERSION=`$(VERSIONCMD)`

clean:
	-rm -R $(DOCSETDIR) 
	-rm -R $(BUILDDIR)

xml $(DISPLAYNAME).xml:
	@echo $(XMLTEXT) > $(BUILDDIR)/$(DISPLAYNAME).xml

tgz $(DISPLAYNAME).tgz:
	@tar --exclude='.DS_Store' -cvzf $(BUILDDIR)/$(DISPLAYNAME).tgz $(DOCSETDIR)

docset $(DOCSETDIR) $(BUILDDIR):
	@$(SPHINXBUILD) -D html_static_path="../../../_static", "$(SOURCEDIR)" "$(BUILDDIR)"
	@$(DASHBUILD) -f -n $(DISPLAYNAME) -i $(ICONNAME) $(BUILDDIR) 
	@sed -i -e '/<key>DocSetPlatformFamily<\/key>/!b;n;c\\t<string>pyg<\/string>' $(PLISTPATH)
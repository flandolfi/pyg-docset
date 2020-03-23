SPHINXBUILD   = sphinx-build
SPHINXPROJ    = pytorch_geometric
SOURCEDIR     = pytorch_geometric/docs/source
BUILDDIR      = build

DISPLAYNAME   = "PyTorch-Geometric"
ICONNAME      = $(BUILDDIR)/icon.png
SVGPROC       = inkscape
SVGOPTS       = -e
DASHBUILD     = doc2dash
DOCSETDIR	  = $(DISPLAYNAME).docset
PLISTPATH     = $(DOCSETDIR)/Contents/Info.plist

XMLTEXT		  = "<entry>" \
	"<version>`cd $(SPHINXPROJ) && git describe --tags`</version>" \
	"<url>https://github.com/flandolfi/pyg-docset/raw/master/$(DISPLAYNAME).tgz</url>" \
"</entry>"

.PHONY: icon docset clean all update


all: docset

update:
	@git submodule foreach git pull

clean-docset:
	-rm -R $(DOCSETDIR) 

clean:
	-rm -R $(BUILDDIR)
	-rm $(DISPLAYNAME).xml 
	-rm $(DISPLAYNAME).tgz

icon ${ICONNAME}:
	mkdir -p $(BUILDDIR)
	@$(SVGPROC) $(SVGOPTS) ${ICONNAME} _static/img/pyg_logo.svg

docset: ${ICONNAME} clean-docset
	@$(SPHINXBUILD) -D html_static_path="../../../_static", "$(SOURCEDIR)" "$(BUILDDIR)"
	@$(DASHBUILD) -n $(DISPLAYNAME) -i $(ICONNAME) $(BUILDDIR) 
	@sed -i -e '/<key>DocSetPlatformFamily<\/key>/!b;n;c\\t<string>pyg<\/string>' $(PLISTPATH)
	@tar --exclude='.DS_Store' -cvzf $(DISPLAYNAME).tgz $(DOCSETDIR)
	@echo $(XMLTEXT) > $(DISPLAYNAME).xml

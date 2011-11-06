#!/use/bin/gmake -f

CWD = $(shell pwd)
CP = ln -s
PLUGINDIR = var/lib/nza/plugins/nmc/nmc-ups

build:

install:
	@$(MAKE) DEB_BUILD=1 CP='cp -d' deploy

clean:

deploy: deploy-clean deploy-dirs deploy-files

deploy-dirs: deploy-clean
	@echo "Deploing dirs..."
	@mkdir -p $(DESTDIR)/$(PLUGINDIR)

deploy-files: deploy-dirs
	@echo "Deploing files..."
	@$(CP) $(CWD)/metafile.pm $(DESTDIR)/$(PLUGINDIR)
	@$(CP) $(CWD)/UPS.pm $(DESTDIR)/$(PLUGINDIR)

ifndef DEB_BUILD
deploy-clean:
	@echo "Cleaning up before deploing..."
	@rm -rf $(DESTDIR)/$(PLUGINDIR)
else
deploy-clean:
endif

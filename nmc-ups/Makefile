#!/use/bin/make -f

CWD = $(shell pwd)
CP = ln -s
PLUGINDIR = var/lib/nza/plugins/nmc/nmc-ups


build:

install:
	@$(MAKE) DEB_BUILD=1 CP='cp -d' deploy

clean:
	@rm -rf $(DESTDIR)/$(PLUGINDIR)

deploy: deploy-dirs deploy-files

deploy-dirs: clean
	@mkdir -p $(DESTDIR)/$(PLUGINDIR)

deploy-files: deploy-dirs
	@$(CP) $(CWD)/metafile.pm $(DESTDIR)/$(PLUGINDIR)
	@$(CP) $(CWD)/UPS.pm $(DESTDIR)/$(PLUGINDIR)

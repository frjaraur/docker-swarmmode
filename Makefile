destroy:
	@vagrant destroy --force || true
	@rm -rf tmp_deploying_stage || true
	@rm -rf /tmp/rexray/volumes || true
	@rm -rf *.vdi
create:
	@vagrant up -d

recreate:
	@make destroy
	@make create

standalone:
	@make destroy
	@vagrant up -d swarm1

stop:
	@VBoxManage controlvm swarm4 acpipowerbutton 2>/dev/null || true
	@VBoxManage controlvm swarm3 acpipowerbutton 2>/dev/null || true
	@VBoxManage controlvm swarm2 acpipowerbutton 2>/dev/null || true
	@VBoxManage controlvm swarm1 acpipowerbutton 2>/dev/null || true

start:
	[ `ps -ef | grep -c vboxwebsrv ` -ne 1 ] && VBoxManage setproperty websrvauthlibrary null && vboxwebsrv -H 0.0.0.0 --background
	@VBoxManage startvm swarm1 --type headless 2>/dev/null || true
	@VBoxManage startvm swarm2 --type headless 2>/dev/null || true
	@VBoxManage startvm swarm3 --type headless 2>/dev/null || true
	@VBoxManage startvm swarm4 --type headless 2>/dev/null || true

status:
	@vagrant status

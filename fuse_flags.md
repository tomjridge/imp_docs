# FUSE command line flags



## Some common flags we often use

Some examples:

| Flag                 | Description                                               |
| -------------------- | --------------------------------------------------------- |
| -f                   | foreground                                                |
| -s                   | single-threaded (almost certainly necessary)              |
| -o allow_other       | needed if run as user, but losetup as root                |
| -o max_write=1048576 | don't attempt writes larger than this; 1048756 = 2^20, 1M |
| -o auto_unmount      | unmount if/when the process dies                          |
| -o big_writes        | enable larger than 4kB writes                             |

Typical example: `./fuse_nfs_client.exe -s -f -o auto_unmount ./fuse_mount`

NOTE: probably run the server in a separate xterm, so that emacs buffering doesn't kill everything



## Suggested flags, compatible with ocamlfuse, which probably significantly affect performance

Obviously running multithreaded is probably useful.

Caching parameters:




~~~
    -o readdir_ino         try to fill in d_ino in readdir        
    -o kernel_cache        cache files in kernel
    -o [no]auto_cache      enable caching based on modification times (off)
    -o negative_timeout=T  cache timeout for deleted names (0.0s)
    -o attr_timeout=T      cache timeout for attributes (1.0s)
    -o ac_attr_timeout=T   auto cache timeout for attributes (attr_timeout)
    -o noforget            never forget cached inodes
    -o remember=T          remember cached inodes for T seconds (0s)
~~~



Further params (including above):

~~~

    -o large_read          issue large read requests (2.4 only)
    -o max_read=N          set maximum size of read requests

    -o use_ino             let filesystem set inode numbers
    -o readdir_ino         try to fill in d_ino in readdir    
    
    -o kernel_cache        cache files in kernel
    -o [no]auto_cache      enable caching based on modification times (off)
    -o negative_timeout=T  cache timeout for deleted names (0.0s)
    -o attr_timeout=T      cache timeout for attributes (1.0s)
    -o ac_attr_timeout=T   auto cache timeout for attributes (attr_timeout)
    -o noforget            never forget cached inodes
    -o remember=T          remember cached inodes for T seconds (0s)

    -o max_write=N         set maximum size of write requests
    -o max_readahead=N     set maximum readahead
    -o max_background=N    set number of maximum background requests
    -o congestion_threshold=N  set kernel's congestion threshold
    -o async_read          perform reads asynchronously (default)
    -o big_writes          enable larger than 4kB writes

~~~



NOTE splice options omitted





## FUSE flags likely to affect performance, or which we may want to consider using



~~~
FUSE options:
    -d   -o debug          enable debug output (implies -f)
    -f                     foreground operation
    -s                     disable multi-threaded operation

    -o large_read          issue large read requests (2.4 only)
    -o max_read=N          set maximum size of read requests

    -o use_ino             let filesystem set inode numbers
    -o readdir_ino         try to fill in d_ino in readdir
    -o direct_io           use direct I/O
    -o kernel_cache        cache files in kernel
    -o [no]auto_cache      enable caching based on modification times (off)
    
    -o entry_timeout=T     cache timeout for names (1.0s)
    -o negative_timeout=T  cache timeout for deleted names (0.0s)
    -o attr_timeout=T      cache timeout for attributes (1.0s)
    -o ac_attr_timeout=T   auto cache timeout for attributes (attr_timeout)
    -o noforget            never forget cached inodes
    -o remember=T          remember cached inodes for T seconds (0s)

    -o max_write=N         set maximum size of write requests
    -o max_readahead=N     set maximum readahead
    -o max_background=N    set number of maximum background requests
    -o congestion_threshold=N  set kernel's congestion threshold
    -o async_read          perform reads asynchronously (default)
    -o sync_read           perform reads synchronously
    -o big_writes          enable larger than 4kB writes

-o [no_]splice_write   use splice to write to the fuse device
    -o [no_]splice_move    move data while splicing to the fuse device
    -o [no_]splice_read    use splice to read from the fuse device

~~~



## Other performance aspects

FUSE has two "levels" of API, low and high. We currently use high. Maybe this is all that is supported by ocamlfuse. However, low would be expected to give better performance (and Vangoor19 paper uses low only, so potentially the performance observations reported there don't apply to us).



ocamlfuse: "The stateful interface for readdir is not implemented" - which might help performance?

ocamlfuse: readdir_plus is not implemented; this would potentially significantly improve performance when readding a dir

https://www.kernel.org/doc/Documentation/filesystems/fuse-io.txt suggests that kernel caching is write-through by default, whereas we may want to enable writeback-cache; this is presumably `-o writeback_cache`. Supported since 2018, but maybe not yet in current distributions.



## Addendum: FUSE options

These are the options listed on my system at 2019-12-02:

~~~
(python3) > ./fuse_in_mem_main.exe --help
usage: ./fuse_in_mem_main.exe mountpoint [options]

general options:
    -o opt,[opt...]        mount options
    -h   --help            print help
    -V   --version         print version

FUSE options:
    -d   -o debug          enable debug output (implies -f)
    -f                     foreground operation
    -s                     disable multi-threaded operation

    -o allow_other         allow access to other users
    -o allow_root          allow access to root
    -o auto_unmount        auto unmount on process termination
    -o nonempty            allow mounts over non-empty file/dir
    -o default_permissions enable permission checking by kernel
    -o fsname=NAME         set filesystem name
    -o subtype=NAME        set filesystem type
    -o large_read          issue large read requests (2.4 only)
    -o max_read=N          set maximum size of read requests

    -o hard_remove         immediate removal (don't hide files)
    -o use_ino             let filesystem set inode numbers
    -o readdir_ino         try to fill in d_ino in readdir
    -o direct_io           use direct I/O
    -o kernel_cache        cache files in kernel
    -o [no]auto_cache      enable caching based on modification times (off)
    -o umask=M             set file permissions (octal)
    -o uid=N               set file owner
    -o gid=N               set file group
    -o entry_timeout=T     cache timeout for names (1.0s)
    -o negative_timeout=T  cache timeout for deleted names (0.0s)
    -o attr_timeout=T      cache timeout for attributes (1.0s)
    -o ac_attr_timeout=T   auto cache timeout for attributes (attr_timeout)
    -o noforget            never forget cached inodes
    -o remember=T          remember cached inodes for T seconds (0s)
    -o nopath              don't supply path if not necessary
    -o intr                allow requests to be interrupted
    -o intr_signal=NUM     signal to send on interrupt (10)
    -o modules=M1[:M2...]  names of modules to push onto filesystem stack

    -o max_write=N         set maximum size of write requests
    -o max_readahead=N     set maximum readahead
    -o max_background=N    set number of maximum background requests
    -o congestion_threshold=N  set kernel's congestion threshold
    -o async_read          perform reads asynchronously (default)
    -o sync_read           perform reads synchronously
    -o atomic_o_trunc      enable atomic open+truncate support
    -o big_writes          enable larger than 4kB writes
    -o no_remote_lock      disable remote file locking
    -o no_remote_flock     disable remote file locking (BSD)
    -o no_remote_posix_lock disable remove file locking (POSIX)
    -o [no_]splice_write   use splice to write to the fuse device
    -o [no_]splice_move    move data while splicing to the fuse device
    -o [no_]splice_read    use splice to read from the fuse device

Module options:

[iconv]
    -o from_code=CHARSET   original encoding of file names (default: UTF-8)
    -o to_code=CHARSET	    new encoding of the file names (default: UTF-8)

[subdir]
    -o subdir=DIR	    prepend this directory to all paths (mandatory)
    -o [no]rellinks	    transform absolute symlinks to relative
~~~


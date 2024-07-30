cd d:/matlab/sockapi_new
mex -DOPEN_CONN -DCOOKED -I/usr/local/include open_conn.c sockfuncs.c user32.lib ws2_32.lib d:\usr\local\lib\wsock32x.lib
mex -DCOOKED open_console.c user32.lib ws2_32.lib
mex -DCOOKED -I/usr/local/include read_conn.c sockfuncs.c user32.lib ws2_32.lib d:\usr\local\lib\wsock32x.lib
mex -I/usr/local/include write_conn.c sockfuncs.c user32.lib ws2_32.lib d:\usr\local\lib\wsock32x.lib
mex -DCOOKED read_console.c user32.lib ws2_32.lib
mex write_console.c user32.lib ws2_32.lib
mex -I/usr/local/include close_conn.c user32.lib
mex -I/usr/local/include close_console.c user32.lib

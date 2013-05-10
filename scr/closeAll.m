t = timerfindall;
stop(t);
delete(t);

fwrite(serialHandler,'s');
s = instrfindall;
fclose(s);
delete(s);

disp('everything is closed')

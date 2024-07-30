%fname = 'Y:\DataNeuro\D98.AT2\2002-9-5_13-45-30\CSC13.Ncs';
fname = '\\Wks20\Data\DataNeuro\D98.AT2\2002-9-5_13-45-30\CSC13.Ncs';

tst = 8194340;
ted = 8494340;

[wdata,cr] = read_cr(fname,'tstart',tst,'tend',ted,'verbose');



fname2 = '\\Wks20\Data\DataNeuro\D98.AT3\2002-3-25_11-33-19\CSC16.Ncs';

tst2 = 38686725;
ted2 = 38986725;

[wdata2,cr2] = read_cr(fname2,'tstart',tst2,'tend',ted2,'verbose');


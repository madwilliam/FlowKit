imageLines = imimportTif(['/home/zhw272/lspiv/' 'capillary.TIF'])';
[velocity,data,LSPIVresult,badsamples] = LSPIV(imageLines);

visualize_lspiv(imageLines,velocity,LSPIVresult,index,badsamples);
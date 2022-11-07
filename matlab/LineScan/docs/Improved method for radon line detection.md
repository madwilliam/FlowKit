# Improved method for radon line detection

sc![image-20220902105743424](/home/zhw272/.config/Typora/typora-user-images/image-20220902105743424.png)

![image-20220902105952335](/home/zhw272/.config/Typora/typora-user-images/image-20220902105952335.png)

### New method improved on the preprocessing method:

#### Old method:

1. subtract image mean
2. subtract temporal mean

### New method:

1. subtract image mean
2. subtract temporal mean
3. gaussian filter
4. kernal denstiy estimation to get shape of histogram
5. find trough between two peaks
6. use trough to threshold image obtaining binary mask



![image-20220902110805698](/home/zhw272/.config/Typora/typora-user-images/image-20220902110805698.png)

New method shows more adherence to human labels
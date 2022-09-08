![image-20220831154247709](/home/zhw272/.config/Typora/typora-user-images/image-20220831154247709.png)

many mis detections of 0 slope

![image-20220831154327806](/home/zhw272/.config/Typora/typora-user-images/image-20220831154327806.png)

Using max value gives good description, but would detect signal band diagnal

![image-20220831154622064](/home/zhw272/.config/Typora/typora-user-images/image-20220831154622064.png)

Combination of max plus variance solves this problem.  We use max value to find a rough range of thetas, and use variance to find the slopt parallel to the edges of signal band

![image-20220831154654467](/home/zhw272/.config/Typora/typora-user-images/image-20220831154654467.png)
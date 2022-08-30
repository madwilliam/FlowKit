Hey Ben,

  I did some testing on simulated data and finds that finding the angle with max R variance, instead of max R value solves the problem where angle fit goes through the diagonal of signal band:

Hey Ben,

  I did some testing on simulated data and finds that finding the angle with max R variance, instead of max R value solves the problem where angle fit goes through the diagonal of signal band:

![image-20220830100517000](/home/zhw272/.config/Typora/typora-user-images/image-20220830100517000.png)



This makes sense due to the intuition we found yesterday:

Where max values finds the diagonal as it produces a secondary signal peak

![image-20220830100552975](/home/zhw272/.config/Typora/typora-user-images/image-20220830100552975.png)



whereas max variance captures the parallel direction where the signal plateaus at the peak:

![image-20220830100624886](/home/zhw272/.config/Typora/typora-user-images/image-20220830100624886.png)



This plateaus means more separation between high and low values, contributing to high variance.

Therefore we should use variance from now on for better accuracy.
# 3DtoCamera
Drawing a pyramid using pure Core Graphics in Swift 3.0

### Result
![1234](https://user-images.githubusercontent.com/22226679/29132506-1aaf08b6-7d39-11e7-9728-5fdbc5b55a80.gif)

## Algorithm
It is necessary to calculate the coordinates of all verteces in the world coordinate system and then in the camera coordinate system. In order to do that, we need to multiply all 3 rotation matrices and 
the result matrix should be used for all verteces. New coordinates will be used for drawing. Z-coordinate will be used just for determination the distance from camera to the facet. And X,Y- coordinates for usual drawing in Cartesian coordinate system.

Another aspect is the calculation of the light intensity for each facet. Just calculate angle between the normal vectors and the light vector. 

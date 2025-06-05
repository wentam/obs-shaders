Misc shaders to use as filters with obs-shaderfilter plugin.

Before using any of these, install obs-shaderfilter.

## remove-background

* Set up your camera in obs with manual/static everything. Static focus, exposure, etc.
* More exposure = more better
    * Turn on exposure-dynamic framerate to get more range, this helps a lot
* Take a photo of the source without you in it by right-clicking the source and clicking screenshot.
    * I like to hide under the desk with my hand on the mouse, kek.
* Add remote-background.glsl as a shader filter with obs-shaderfilter
* Select your background image in the filter settings
* Adjust threshold, suckIn and averageDistance until it's pretty.
    * suckIn is awesome for getting rid of noise and compensating for ballooning from the averaging.


function newImage(arg) {
	if (document.images) {
		rslt = new Image();
		rslt.src = arg;
		return rslt;
	}
}

function changeImages() {
	if (document.images && (preloadFlag == true)) {
		var img;
		for (var i=0; i<changeImages.arguments.length; i+=2) {
			img = $(changeImages.arguments[i]);
			if (img) {
				img.src = changeImages.arguments[i+1];
			}
		}
	}
}

var preloadFlag = false;
if(typeof(baseJSUrl) == "undefined")
{
  var baseJSUrl = "http://"+window.location.host;  
}
function preloadImages() {
	if (document.images) {
		sponsorship_over = newImage(baseJSUrl + "/site/images/sponsorship-over.gif");
		sponsorship_down = newImage(baseJSUrl + "/site/images/sponsorship-down.gif");
		about_over = newImage(baseJSUrl + "/site/images/about-over.gif");
		about_down = newImage(baseJSUrl + "/site/images/about-down.gif");
		donation_over = newImage(baseJSUrl + "/site/images/donation-over.gif");
		donation_down = newImage(baseJSUrl + "/site/images/donation-down.gif");
		gallery_over = newImage(baseJSUrl + "/site/images/gallery-over.gif");
		gallery_down = newImage(baseJSUrl + "/site/images/gallery-down.gif");
		newsevents_over = newImage(baseJSUrl + "/site/images/newsevents-over.gif");
		newsevents_down = newImage(baseJSUrl + "/site/images/newsevents-down.gif");
		preloadFlag = true;
	}
}
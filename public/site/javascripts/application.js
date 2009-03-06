function changeUser(element)
{
//	alert("change user: " + element.value);
	window.location = '/projects/show_user/'+element.value;
}

function changeProject(element)
{
//	alert("changeProject: " + element.value);
	window.location = '/projects/show/'+element.value;
}

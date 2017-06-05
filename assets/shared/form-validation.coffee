$("form.validate").validate({
	highlight: (element) -> $(element).closest(".form-group").addClass("has-error")
	unhighlight: (element) -> $(element).closest(".form-group").removeClass("has-error")
	errorElement: "span"
	errorClass: "help-block text-danger"
	errorPlacement: (error, element) ->
		if (element.closest(".form-group").length)
			element.closest(".form-group").append(error)
		else
			error.insertAfter(element)
})

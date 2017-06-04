$(document).ready(() ->

	fields = $("div.form-check")
	fields.each((i, wrapper) ->
		wrapper = $(wrapper)

		# get elements
		label = wrapper.find("label")
		input = wrapper.find("input")

		# create icon and fix position
		icon = $("<i class=\"fa fa-fw\"></i>")
		label.prepend(icon)
		label.css({ "paddingLeft": 0 })
		icon.css({ "marginRight": "8px" })
		input.hide()

		# watch input and mirror state in icon
		update = () ->
			if (input.is(":checked"))
				icon.removeClass("text-muted").removeClass("fa-square-o").addClass("fa-check-square-o")
			else
				icon.addClass("text-muted").removeClass("fa-check-square-o").addClass("fa-square-o")
		wrapper.bind("check:update", () -> update())
		input.change(() -> fields.trigger("check:update"))

		# show initial state
		update()
	)
)

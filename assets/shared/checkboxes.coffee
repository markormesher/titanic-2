$(document).ready(() ->

	fields = $("div.form-check")
	fields.each((i, wrapper) ->
		wrapper = $(wrapper)

		# get elements
		label = wrapper.find("label")
		input = wrapper.find("input")

		# create icon and fix position
		customIcon = true
		icon = wrapper.find(".icon")
		if (!icon.length)
			customIcon = false
			icon = $("<i class=\"fa fa-fw\"></i>")
			label.prepend(icon)
			icon.css({ "marginRight": "8px" })

		# remove unused items
		label.css({ "paddingLeft": 0 })
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

window.toastr.options.closeButton = true
window.toastr.options.timeOut = 1000
window.toastr.options.extendedTimeOut = 10000
window.toastr.options.progressBar = true

$(document).ready(() ->
	for type, messages of window.toastrMessages
		for msg in messages
			switch type
				when 'error' then toastr.error(msg)
				when 'info' then toastr.info(msg)
				when 'success' then toastr.success(msg)
				when 'warning' then toastr.warning(msg)
)

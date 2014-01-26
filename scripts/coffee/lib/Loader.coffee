module.exports = class LoadFile

	constructor: ->

		@ajax = new XMLHttpRequest()

		@ajax.addEventListener("progress", @_updateProgress, false)
		@ajax.addEventListener("load", @_transferComplete, false)
		@ajax.addEventListener("error", @_transferFailed, false)
		@ajax.addEventListener("abort", @_transferCanceled, false)

		@list = []
		@cbs = []

		@_events = {}

	_transferComplete: (file) =>

		@cbs.pop()(file)

		@countUp++

		console.log "Loader: file loaded!"

		@_loadFile @list.pop()

		return

	_transferFailed: ->

		console.error 'Loader: error downloading file!'

		return

	_transferCanceled: ->

		console.error 'Loader: ehhh, downloading canceled!'

		return

	_updateProgress: (oEvent) =>

		if oEvent.lengthComputable

			percentComplete = (@countUp / @count) + (oEvent.loaded / (oEvent.total * @count))

			console.log 'Loader: Downloading file, current progress: ', percentComplete

		else

			console.log 'Loader: Unable to compute progress information since the total size is unknown!'

		return

	get: (url, cb) ->

		@list.push url
		@cbs.push cb

	load: ->

		@_events.start() if @_events.start?

		@count = @list.length

		@countUp = 0

		@_loadFile @list.pop()

	_loadFile: (url) ->

		if url is undefined or url is null

			@_events.done() if @_events.done?

			return

		@ajax.open "GET", url, true # <-- the 'false' makes it synchronous

		@ajax.send null

		return

	on: (job, callback) ->

		@_events[job] = callback
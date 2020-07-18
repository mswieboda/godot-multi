extends Node

var http = HTTPClient.new()

func request(base_url, path, headers = [], method = HTTPClient.METHOD_GET):
	var err = OK
	err = http.connect_to_host(base_url, -1, true)

	if err != OK:
		print("connect error:", err)
		return {
			code = 500,
			body = ""
		}

	while http.get_status() == HTTPClient.STATUS_CONNECTING or http.get_status() == HTTPClient.STATUS_RESOLVING:
		http.poll()
		OS.delay_msec(300)

	if http.get_status() != HTTPClient.STATUS_CONNECTED:
		print("connecting status error:", http.get_status())
		return {
			code = 500,
			body = ""
		}

	var all_headers = [
		"User-Agent: Pirulo/1.0 (Godot)",
		"Content-Type: application/json",
		"Accept: */*"
	]
	all_headers += headers

	err = http.request(method, "/" + path, all_headers)
	if err != OK:
		print("request error:", err)
		return {
			code = 500,
			body = ""
		}

	while http.get_status() == HTTPClient.STATUS_REQUESTING:
		http.poll()
		OS.delay_msec(300)

	if http.has_response():
		var bytes = PoolByteArray()
		var response_headers = http.get_response_headers_as_dictionary()

		while http.get_status() == HTTPClient.STATUS_BODY:
			http.poll()
			var chunk = http.read_response_body_chunk()
			if chunk.size() > 0:
				OS.delay_usec(1000)
			else:
				bytes += chunk

		var code = http.get_response_code()
		var body = bytes.get_string_from_ascii()

		http.close()

		return {
			code = code,
			body = body
		}

func get_(base_url, path, headers = []):
	print("GET:", base_url + "/" + path)
	return request(base_url, path, headers)

func post(base_url, path, headers = []):
	print("POST:", base_url + "/" + path)
	return request(base_url, path, headers, HTTPClient.METHOD_POST)

func delete(base_url, path, headers = []):
	print("DELETE:", base_url + "/" + path)
	return request(base_url, path, headers, HTTPClient.METHOD_DELETE)

func patch(base_url, path, headers = []):
	print("PATCH:", base_url + "/" + path)
	return request(base_url, path, headers, HTTPClient.METHOD_PATCH)

func put(base_url, path, headers = []):
	print("PUT:", base_url + "/" + path)
	return request(base_url, path, headers, HTTPClient.METHOD_PUT)

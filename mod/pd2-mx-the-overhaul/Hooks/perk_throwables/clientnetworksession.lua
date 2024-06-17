function ClientNetworkSession:send_to_host(...)
	if self._server_peer then
		self._server_peer:send(FakeNadeSync(1, ...))
	end
end
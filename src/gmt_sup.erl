%%%-------------------------------------------------------------------
%%% Copyright: (c) 2007-2010 Gemini Mobile Technologies, Inc.  All rights reserved.
%%%
%%% Licensed under the Apache License, Version 2.0 (the "License");
%%% you may not use this file except in compliance with the License.
%%% You may obtain a copy of the License at
%%%
%%%     http://www.apache.org/licenses/LICENSE-2.0
%%%
%%% Unless required by applicable law or agreed to in writing, software
%%% distributed under the License is distributed on an "AS IS" BASIS,
%%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%%% See the License for the specific language governing permissions and
%%% limitations under the License.
%%%
%%% File    : gmt_sup.erl
%%% Purpose : Top-level gmt supervisor
%%%-------------------------------------------------------------------

-module(gmt_sup).

-behaviour(supervisor).

-include("applog.hrl").

%% API
-export([start_link/1]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

%%====================================================================
%% API functions
%%====================================================================
%%--------------------------------------------------------------------
%% Function: start_link() -> {ok,Pid} | ignore | {error,Error}
%% Description: Starts the supervisor
%%--------------------------------------------------------------------
start_link([]) ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%====================================================================
%% Supervisor callbacks
%%====================================================================
%%--------------------------------------------------------------------
%% Func: init(Args) -> {ok,  {SupFlags,  [ChildSpec]}} |
%%                     ignore                          |
%%                     {error, Reason}
%% Description: Whenever a supervisor is started using
%% supervisor:start_link/[2,3], this function is called by the new process
%% to find out about restart strategy, maximum restart frequency and child
%% specifications.
%%--------------------------------------------------------------------
init([]) ->
    %% Hint:
    %% Child_spec = [Name, {M, F, A},
    %%               Restart, Shutdown_time, Type, Modules_used]

    CentralConfig = gmt_config:get_config_file_path(),
    ConfigSrv =
        {gmt_config_svr, {gmt_config_svr, start_link, [CentralConfig]},
         permanent, 2000, worker, [gmt_config_svr]},

    SysMonSrv =
        {gmt_sysmon_server, {gmt_sysmon_server, start_link, []},
         permanent, 2000, worker, [gmt_sysmon_server]},

    %% GMT diff: delete
    TLogSrv =
        {gmt_tlog_svr, {gmt_tlog_svr, start_link, []},
         permanent, 2000, worker, [gmt_tlog_svr]},

    CLIPort = gmt_config:get_config_value_i(cli_port, 0),
    CLIModule = gmt_config:get_config_value(cli_module, undefined),
    CLIPrompt = gmt_config:get_config_value(cli_prompt, "CLI> "),
    CLIHello = gmt_config:get_config_value(cli_hello, "GMT CLI Server"),
    CLISrv = {gmt_cli, {gmt_cli, start_link,
                        [CLIPort,CLIModule,CLIPrompt,CLIHello]},
              permanent, 2000, worker, [gmt_cli]},

    Servers = if CLIPort > 0 ->
                      [ConfigSrv, TLogSrv, SysMonSrv, CLISrv];
                 true ->
                      [ConfigSrv, TLogSrv, SysMonSrv]
              end,
    {ok, {{one_for_one, 15, 60}, Servers}}.

%%====================================================================
%% Internal functions
%%====================================================================

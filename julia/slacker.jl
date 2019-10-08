# This sends a message to slack
using HTTP
using JSON



function getWebHookURL()
    f = ".slack_webhook"
    s = read(f, String)
    chop(s)
end

function sendSlackMessage(channel, text; username = "JuliaBot", icon_emoji = ":ghost:")
    a = Dict(
        "channel" => channel,
        "username" => username,
        "text" => text,
        "icon_emoji" => icon_emoji)

    message = "payload=" * json(a)
    webhook = getWebHookURL()
    HTTP.request("POST",
        webhook,
        ["Content-Type" => "application/x-www-form-urlencoded"], message;
        verbose = 0)
end

#sendSlackMessage("#digimuen", "Cool, now I can send to Slack from Julia";
#                icon_emoji = ":juliabot:")






#message = "payload={\"channel\": \"#digimuen\", \"username\": \"webhookbot\","*
#            " \"text\": \"This is posted to #digimuen and comes from a bot named webhookbot.\"," *
#            " \"icon_emoji\": \":ghost:\"}"

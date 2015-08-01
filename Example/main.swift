//
// main.swift
//
// This file containing the example code is in public domain.
// Feel free to copy-paste it and edit it in any way you like.
//

import Foundation

let environment = NSProcessInfo.processInfo().environment
guard let token = environment["TelegramExampleBotToken"] else {
    fatalError("Please set TelegramExampleBotToken environment variable")
}

let bot = TelegramBot(token: token)

class Controller {
    let bot: TelegramBot
    var message: Message { return bot.lastMessage }

    func privateResponse(text: String, groupText: String? = nil) {
        bot.sendMessage(chatId: message.from.id, text: text)
        if let groupText = groupText {
            if case .GroupChatType = message.chat {
                bot.sendMessage(chatId: message.chat.id, text: groupText)
            }
        }
    }
    
    func groupResponse(groupText: String) {
        bot.sendMessage(chatId: message.chat.id, text: groupText)
    }
    
    init(bot: TelegramBot) {
        self.bot = bot
    }
    
    func start() {
        groupResponse("Start")
    }
    
    func help() {
        let helpText = "What can this bot do?\n" +
            "\n" +
            "This is a sample bot which shuffles letters inside of words. " +
            "If you want to invite friends, simply open the bot's profile " +
            "and use the 'Add to group' button to invite them.\n" +
            "\n"
            "Send /start to begin shuffling letters.\n"
            "Tell the bot to /stop when you're done."
        
        privateResponse(helpText,
            groupText: "\(message.from.firstName), please find usage instructions in a personal message.")
    }
    
    func settings() {
        privateResponse("Settings",
            groupText: "\(message.from.firstName), please find a list of settings in a personal message.")
    }

    func partialMatchHandler(unmatched: String, args: Arguments, path: Path) {
        groupResponse("❗ Part of your input was ignored: \(unmatched)")
    }

    func defaultHandler(args: Arguments) {
        let text = args["text"].stringValue
        
        groupResponse("I guess I don't understand what this command means: \(text)")
    }
}

let controller = Controller(bot: bot)

let router = Router(partialMatchHandler: controller.partialMatchHandler)
router.addPath([Command("start")], controller.start)
router.addPath([Command("help")], controller.help)
router.addPath([Command("settings")], controller.settings)
router.addPath([RestOfString("text")], controller.defaultHandler)

print("Ready to accept commands")
while let command = bot.nextCommand() {
    print("--- updateId: \(bot.lastUpdate!.updateId)")
    print("message: \(bot.lastMessage.prettyPrint)")
    router.processString(command)
}
fatalError("Server stopped due to error: \(bot.lastError)")

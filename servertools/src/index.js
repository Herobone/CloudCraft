const Compute = require("@google-cloud/compute");
const VM = require("@google-cloud/compute/src/vm");
const Discord = require("discord.js");
const token = process.env.NODE_ENV !== "production" ? require("../discord.json").token : process.env.DISCORD_TOKEN;
const vmName = process.env.VM_NAME ? process.env.VM_NAME : "test-instance-docker";

const client = new Discord.Client();
const compute = new Compute();

/**
 * Format a VM and output to console
 * @param vm {VM}
 */
const format = (vm) => {
    console.log(`Name: ${vm.name}`);
    console.log(`   Status: ${vm.metadata.status}`);
    console.log(
        `   Network: \n${vm.metadata.networkInterfaces.map(
            (ni, index) =>
                `       Interface ${index}: ${ni.accessConfigs.map(
                    /**
                     *
                     * @param config The access config of the Interface
                     * @param config.type {string} Type of the Access Config
                     * @param config.name {string} Name of the interface
                     * @param config.networkTier {string} Tier of Networking
                     * @param config.natIP? {string} External IP
                     * @param index1 {number}
                     * @returns {string[]}
                     */
                    (config, index1) => [
                        `\n           Access ${index1} NAT IP: ${config.natIP}`,
                        `\n           Access ${index1} Type: ${config.type}`,
                    ],
                )}\n`,
        )}`,
    );
    console.log(`   Tags: ${vm.metadata.tags.items}`);
};

/**
 *
 * @param vm {VM}
 */
function getIPs(vm) {
    return vm.metadata.networkInterfaces.map(
        (ni, index) =>
            `Interface ${index}: ${ni.accessConfigs.map(
                /**
                 *
                 * @param config The access config of the Interface
                 * @param config.type {string} Type of the Access Config
                 * @param config.name {string} Name of the interface
                 * @param config.networkTier {string} Tier of Networking
                 * @param config.natIP? {string} External IP
                 * @param index1 {number}
                 * @returns {string[]}
                 */
                (config, index1) => [`\n     Access ${index1} NAT IP: ${config.natIP}`],
            )}\n`,
    );
}

/**
 *
 * @param tags {string[]}
 */
const checkVMTags = (tags) => {
    return tags.includes("http-server");
};

/**
 *
 * @param vms {VM[]}
 */
const listVMS = (vms) => {
    console.log(vms);
    vms.forEach((vm) => {
        format(vm);
    });
};

/**
 *
 * @param vms {VM[]}
 * @param name {string} Name of the vm to look for
 * @return {VM}
 */
function getVM(vms, name) {
    return vms.find((vm) => vm.name === name);
    /*    return vms.map((vm) => {
        if (vm.name === name) {
            console.log("Server found!");
            return vm;
        }
    })[0];*/
}

const prefix = "!";

/**
 *
 * @param message {Message}
 * @returns {Promise<void>}
 */
async function pingCommand(message) {
    const timeTaken = Date.now() - message.createdTimestamp;
    await message.reply(`Pong! This message had a latency of ${timeTaken}ms.`);
}

/**
 *
 * @param message {Message}
 * @param arguments_ {string[]}
 * @returns {Promise<void>}
 */
async function processServerCommand(message, arguments_) {
    if (arguments_.length === 0) {
        await message.react("❌");
        await message.reply("Too few arguments! Type *!server help* for commands");
        return;
    }
    const react = await message.react("👍");
    const error = async () => {
        await react.remove();
        await message.react("❌");
    };
    const vms = await compute.getVMs({
        maxResults: 10,
    });
    const vm = getVM(vms[0], vmName);
    switch (arguments_[0]) {
        case "status": {
            await message.reply("Server is " + (vm.metadata.status === "RUNNING" ? "online" : "offline"));
            break;
        }
        case "start": {
            if (vm.metadata.status !== "TERMINATED") {
                await error();
                await message.reply("Server is already running!");
            } else {
                try {
                    await vm.start();
                    await message.reply("Server started! Have patience!");
                } catch {
                    await error();
                    await message.channel.send("Failed to start server!");
                }
            }
            break;
        }
        case "ip": {
            await message.channel.send(`Network information:\n${getIPs(vm)}`);
            break;
        }
        case "stop": {
            if (vm.metadata.status !== "RUNNING") {
                await error();
                await message.channel.send("Server is already stopped!");
            } else {
                const message_ = await message.reply("Stop server? React to this message to stop it!");
                await message_.react("👌");
                const filter = (reaction, user) => reaction.emoji.name === "👌" && user.id === message.author.id;
                message_
                    .awaitReactions(filter, { time: 7000, maxUsers: 1 })
                    .then(async (collected) => {
                        console.log(`Collected ${collected.size} reactions`);
                        if (collected.size >= 1) {
                            try {
                                await vm.stop();
                                return message.channel.send("Server stopped!");
                            } catch {
                                await error();
                                return message.channel.send("Failed to stop server!");
                            }
                        } else {
                            await error();
                            return message.reply("You answered not fast enough! Aborting!");
                        }
                    })
                    .catch(console.error);
            }
            break;
        }
        default: {
            await message.reply(`Unrecognised command "${arguments_[0]}"`);
            await error();
            break;
        }
    }
}

/**
 * Processes a command to the bot
 * @param message {Message}
 * @param command {string}
 * @param arguments_ {string[]}
 * @returns {Promise<void>}
 */
async function processCommand(message, command, arguments_) {
    if (command === "ping") {
        await pingCommand(message);
    } else if (command === "server") {
        await processServerCommand(message, arguments_);
    }
}

/**
 *
 * @param message {Message}
 */
async function onMessage(message) {
    if (message.author.bot) return;
    if (!message.content.startsWith(prefix)) return;

    const commandBody = message.content.slice(prefix.length);
    const arguments_ = commandBody.split(" ");
    const command = arguments_.shift().toLowerCase();
    await processCommand(message, command, arguments_);
}

async function main() {
    client.login(token).catch(console.error);
    client.on("message", onMessage);
    client.on("ready", () => console.log(`Ready! VM name is ${vmName}`));
}
main().catch(console.error);

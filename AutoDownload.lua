--[[
    Script simples para automatizar o download sequencial de vários arquivos em bots xdcc limitados.
    
    Autor: Lucas
    Modificado: 06/03/206
    Licença: GPL3

    Nota do autor: do your jumps
]]

hexchat.register("AutoDownload", "0.6.2", "Solicita o próximo pack automaticamente")

------------------------------------------------------------------------------
-- variaveis globais
------------------------------------------------------------------------------
local pack_index = 0 
local download_limit = 0
local simultaneous = 2
local wait = 0

local inited = false

local cmd = ""
local cmd_message = "msg AutoDownload -- "
------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- funções de apoio
------------------------------------------------------------------------------
function is_valid_number(number_str)
    if #number_str > 1 and string.sub(number_str, 1, 1) == "#" then
        local n = tonumber(string.sub(number_str, 2))
        if n > 0 then
            return n
        end
    end
    return nil
end

function print_help(with_separator)
    hexchat.command(cmd_message .. "Para iniciar os downloads use o comando completo:")
    hexchat.command(cmd_message .. "\"/AutoDownload <bot> xdcc send #<primeiro> #<último>\"")
    hexchat.command(cmd_message .. "Substitua o que estiver entre <> pelos valores desejados")
    hexchat.command(cmd_message .. "")
    hexchat.command(cmd_message .. "Comandos auxiliares")
    hexchat.command(cmd_message .. "Comando /AutoDownload \"argumentos\"")
    hexchat.command(cmd_message .. "\"state\" mostra estado atual")
    hexchat.command(cmd_message .. "\"simultaneous\" seguido de um número define o limite de arquivos por vez (limite de 4)")
    hexchat.command(cmd_message .. "\"to\" seguido de um número redefine até qual pack baixar (só funciona depois de começar a baixar)")
    hexchat.command(cmd_message .. "\"stop\" para de solicitar novos downloads (downloads em andamento continuam executando)")
end

function print_state()
    hexchat.command(cmd_message .. "Baixando do pack #" .. pack_index .. " até o pack #" .. download_limit)
    hexchat.command(cmd_message .. "Máximo de " .. simultaneous .. " arquivos por vez")
end

function print_finish(finish_message)
    hexchat.command(cmd_message .. "Finalizado")
    hexchat.command(cmd_message .. "Pack atual: " .. pack_index - 1)
    hexchat.command(cmd_message .. finish_message)
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Funções de hooks
------------------------------------------------------------------------------
function download_next_pack (words, word_eols)

    if inited then
        if pack_index > download_limit then
            print_finish("Fim da lista atingido")
            inited = false
        elseif wait > 0 then
            wait = wait - 1
        else
            hexchat.command(cmd_message .. "Solicitando: " .. cmd .. pack_index)
            hexchat.command(cmd .. pack_index)
            pack_index = pack_index + 1
        end
    end

    return hexchat.EAT_NONE
end

function parse_user_entry(words, word_eols)

    if #words == 2 then
        if words[2] == "state" then
            if inited then
                print_state(tre)
            else
                hexchat.command(cmd_message .. "Fazendo nada :3")
            end
        elseif words[2] == "help" then
            print_help()
        elseif "stop" then
            inited = false
            print_finish("Downloads em andamento continuarão!")          
        end
    elseif #words == 3 then
        if words[2] == "to" then
            local number = tonumber(words[3])
            if inited and number ~= nil and number > 0 then
                download_limit = number
                hexchat.command(cmd_message .. "Baixando até o pack: #" .. download_limit)
            end
        elseif words[2] == "simultaneous" then

            local number = tonumber(words[3])

            if number ~= nil and number > 0 and number < 5 then
                if number == simultaneous then
                    hexchat.command(cmd_message .. "Continunado com " .. simultaneous .. " arquivos por vez")
                else
                    if number < simultaneous then
                        wait = simultaneous - number
                    elseif number > simultaneous then
                        for I = 1, number - simultaneous do
                            download_next_pack(nil, nil)
                        end
                    end
                    simultaneous = number
                    hexchat.command(cmd_message .. "Mundando para " .. simultaneous .. " arquivos por vez")
                end
            end
        end
    elseif #words == 6 and words[3] == "xdcc" and words[4] == "send" then
        local start = is_valid_number(words[5])
        local to = is_valid_number(words[6])

        if start ~= nil and to ~= nil then
            
            cmd = "msg "
            for i = 2, 4 do
                cmd = cmd .. words[i] .. " "
            end
            cmd = cmd .. "#"
            -- Espera-se esse resultado:
            -- cmd = "msg <bot> xdcc send #"
            
            pack_index = start
            download_limit = to

            inited = true

            hexchat.command(cmd_message .. "Começando")
            hexchat.command(cmd_message .. "Bot alvo: " .. words[2])
            print_state(false)

            -- Downloads simultâneos 
            for i = 1, simultaneous do
                download_next_pack(nil, nil)
            end
        end
    end
    return hexchat.EAT_ALL
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Hooks
--[[ Notas:
    print, quando algo é imprimido
    command, quando um comando é executado (inclusive os disparados pelo script)
]]
------------------------------------------------------------------------------
hexchat.hook_print("DCC RECV Complete", download_next_pack)
hexchat.hook_command("AutoDownload", parse_user_entry)
------------------------------------------------------------------------------

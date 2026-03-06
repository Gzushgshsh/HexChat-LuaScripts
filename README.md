# HexChat-LuaScripts
Script(s) para o client de IRC HexChat escrito(s) em lua, confira a [documentação oficial](https://hexchat.readthedocs.io/en/latest/addons.html) para saber mais

## AutoDownload
#### Antes de usar certifique-se de configurar o HexChat para salvar automaticamente os arquivos oferecidos  
Para iniciar os downloads use o comando (substitua o que estiver entre <> pelos valores desejados):

    /AutoDownload <bot> xdcc send #<primeiro> #<último>

Para comandos extras use:
  
    /AutoDownload "argumento"

"help" mostra informações de como usar  
"state" mostra estado atual  
"simultaneous" seguido de um número define o limite de arquivos por vez (limite de 4)  
"to" seguido de um número redefine até qual pack baixar (só funciona depois de começar a baixar)  
"stop" para de solicitar novos downloads (downloads em andamento continuam executando)
#

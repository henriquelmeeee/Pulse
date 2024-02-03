volatile void kmain();
volatile void kentrypoint() { kmain(); }


// DESIGN:
// stdio.h = kprintf()
// por enquanto os processos irão escrever na tela por meio de syscall
// kmmap() = mapeia um endereço virtual pra um endereço físico aleatório
    // será usado por funções como:
        // mmap() (syscall)
        // task create (initialize stack, code)
// teremos uma lista de endereços físicos em uso
// a paginação do Kernel consistirá em identity-mapping pra toda memória
// mas ele só poderá usar os primeiros 1GB pra ele

// os endereços físicos usados pelos dispositivos serão jogados para os 128GB de memória
// eles serão mapeados pra lá através de um kmmap_device() que começa no 128GB

#include "preload.h"
#include "Boot/structs.h"
volatile void kmain() {
    // 0x500 = addr do memory map
    HAL::Initialize();
    kprintf("Hello World!");
}

#Script para realizar desde el punto 1 hasta el 6 del archivo guía de Andrés para la creación de una llamada al sistema
#FAVOR DE MODIFICAR EL CÓDIGO SEGÚN SEA NECESARIO!!!!



# Descarga del kernel y descomprime el mismo...
curl -o ./Kernel_De_Linux.tar.xz "https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.4.259.tar.xz"
tar -xJf Kernel_De_Linux.tar.xz -C ./

#Creación de los archivos necesarios para las syscalls...
mkdir ./linux-5.4.259/terejaker 
touch ./linux-5.4.259/terejaker/tere_syscall.c 

#Programa para realizar operaciones según una entrada...
echo '
#include <linux/kernel.h>
#include <linux/syscalls.h>

SYSCALL_DEFINE3(teresyscall, char*, operation, char*, str1, char*, str2)
{
    long num1, num2, result;
    
    if (kstrtol(str1, 10, &num1) || kstrtol(str2, 10, &num2)) {
        printk("Entrada INCORRECTA: Ambas entradas deben ser de tipo INT.\n");
        return -EINVAL;
    }

    if (strcmp(operation, "suma") == 0) {
        result = num1 + num2;
    } else if (strcmp(operation, "resta") == 0) {
        result = num1 - num2;
    } else if (strcmp(operation, "multiplicacion") == 0) {
        result = num1 * num2;
    } else if (strcmp(operation, "division") == 0) {
        if (num2 == 0) {
            printk("Division entre 0 no permitida.\n");
            return -EINVAL;
        }
        result = num1 / num2;
    } else {
        printk("Operacion INVALIDA. Operaciones permitidas: \n\" suma \"\n\" resta \"\n\" multiplicacion \"\n \"\n division \"\n");
        return -EINVAL;
    }

    printk("RESULTADO EN EL KRB: %ld\n", result);
    pr_info("RESULTADO EN CONSOLA: %ld\n", result);
    
    return result;
}
' >> ./linux-5.4.259/terejaker/tere_syscall.c

echo 'obj-y := teresyscall.o' >> ./linux-5.4.259/terejaker/Makefile
sed -i '1055s|$|terejaker/|' linux-5.4.259/Makefile 
sed -i '1423i asmlinkage long sys_teresyscall(char* str);' ./linux-5.4.259/include/linux/syscalls.h
echo '548 common teresyscall sys_teresyscall' >> ./linux-5.4.259/arch/x86/entry/syscalls/syscall_64.tbl

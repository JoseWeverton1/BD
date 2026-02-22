import psycopg2
from datetime import datetime

#Função de conexão
def conexao():
    return psycopg2.connect(
        host="clinica-db.cahqr2roscot.us-east-1.rds.amazonaws.com",
        database="BD",
        user="professor",
        password="professor",
        port="5432"
    )

#Validações
def validar_cpf(cpf):
    return cpf.isdigit() and len(cpf) == 11

def validar_data(data):
    try:
        return datetime.strptime(data, "%Y-%m-%d").date()
    except:
        return None

def validar_hora(hora):
    try:
        return datetime.strptime(hora, "%H:%M").time()
    except:
        return None

def validar_int(valor):
    try:
        return int(valor)
    except:
        return None

def validar_float(valor):
    try:
        return float(valor)
    except:
        return None

#Menu
def menu():
    print("\n===== MENU =====")
    print("1. Adicionar")
    print("2. Listar")
    print("3. Atualizar")
    print("4. Deletar")
    print("5. Sair")

#Funções de lsitar
def listar_animais():
    conex = conexao()
    cursor = conex.cursor()

    cursor.execute("SELECT * FROM clinica.animal")

    print("\nFORMATO:")
    print("(id_chave:str(9), raca:str, nome:str, especie:str, tutor_cpf:int, data:date, idade:int)\n")

    for linha in cursor.fetchall():
        print(linha)

    cursor.close()
    conex.close()

def listar_veterinarios():
    conex = conexao()
    cursor = conex.cursor()

    cursor.execute("SELECT * FROM clinica.veterinario")

    print("\nFORMATO:")
    print("(cpf:int, crmv:str, especialidade:str)\n")

    for linha in cursor.fetchall():
        print(linha)

    cursor.close()
    conex.close()

def listar_consultas():
    conex = conexao()
    cursor = conex.cursor()

    cursor.execute("SELECT * FROM clinica.consulta")

    print("\nFORMATO:")
    print("(id:int, diagnostico:str, hora:HH:MM, data:YYYY-MM-DD, animal:str, cpf_vet:int)\n")

    for linha in cursor.fetchall():
        print(linha)

    cursor.close()
    conex.close()


#Funções de inserção
def inserir_animal():
    conex = conexao()
    cursor = conex.cursor()

    print("\nFORMATO:")
    print("ID: até 9 caracteres")
    print("CPF: 11 números")
    print("Data: YYYY-MM-DD")
    print("Idade: inteiro >=0\n")

    id_chave = input("ID animal: ")

    if len(id_chave) > 9:
        print("ID inválido.")
        return

    cursor.execute("SELECT 1 FROM clinica.animal WHERE id_chave=%s", (id_chave,))
    if cursor.fetchone():
        print("Animal já existe.")
        return

    nome = input("Nome: ")
    especie = input("Espécie: ")
    raca = input("Raça: ")

    cpf = input("CPF tutor: ")

    if not validar_cpf(cpf):
        print("CPF inválido.")
        return

    cpf = int(cpf)

    cursor.execute("SELECT 1 FROM clinica.tutor WHERE tutor_cpf=%s", (cpf,))

    if not cursor.fetchone():

        print("Tutor não existe.")

        if input("Criar tutor? (s/n): ") != "s":
            return

        nome_t = input("Nome tutor: ")
        sobrenome = input("Sobrenome tutor: ")

        cursor.execute(
            "INSERT INTO clinica.pessoa VALUES (%s,%s,%s)",
            (cpf, nome_t, sobrenome)
        )

        data = input("Data cadastro YYYY-MM-DD: ")
        data = validar_data(data)

        if not data:
            print("Data inválida.")
            return

        cursor.execute(
            "INSERT INTO clinica.tutor VALUES (%s,%s)",
            (cpf, data)
        )

    data = input("Data nascimento YYYY-MM-DD: ")
    data = validar_data(data)

    if not data:
        print("Data inválida.")
        return

    idade = validar_int(input("Idade: "))

    if idade is None or idade < 0:
        print("Idade inválida.")
        return

    cursor.execute("""
        INSERT INTO clinica.animal
        VALUES (%s,%s,%s,%s,%s,%s,%s)
    """, (id_chave, raca, nome, especie, cpf, data, idade))

    conex.commit()

    print("Inserido com sucesso.")

    cursor.close()
    conex.close()

def inserir_veterinario():
    conex = conexao()
    cursor = conex.cursor()

    print("\nFORMATO:")
    print("CPF: 11 números")
    print("Salário: número decimal")
    print("CRMV: texto único\n")

    cpf = input("CPF: ")

    if not validar_cpf(cpf):
        print("CPF inválido.")
        return

    cpf = int(cpf)

    cursor.execute("SELECT 1 FROM clinica.pessoa WHERE cpf=%s", (cpf,))

    if not cursor.fetchone():

        nome = input("Nome: ")
        sobrenome = input("Sobrenome: ")

        cursor.execute(
            "INSERT INTO clinica.pessoa VALUES (%s,%s,%s)",
            (cpf, nome, sobrenome)
        )

    cursor.execute("SELECT 1 FROM clinica.funcionario WHERE funcionario_cpf=%s", (cpf,))

    if not cursor.fetchone():

        matricula = input("Matrícula: ")

        salario = validar_float(input("Salário: "))

        if salario is None:
            print("Salário inválido.")
            return

        cursor.execute(
            "INSERT INTO clinica.funcionario VALUES (%s,%s,%s)",
            (cpf, matricula, salario)
        )

    crmv = input("CRMV: ")

    cursor.execute("SELECT 1 FROM clinica.veterinario WHERE crmv=%s", (crmv,))

    if cursor.fetchone():
        print("CRMV já existe.")
        return

    esp = input("Especialidade: ")

    cursor.execute(
        "INSERT INTO clinica.veterinario VALUES (%s,%s,%s)",
        (cpf, crmv, esp)
    )

    conex.commit()

    print("Inserido com sucesso.")

    cursor.close()
    conex.close()

def inserir_consulta():
    conex = conexao()
    cursor = conex.cursor()

    print("\nFORMATO:")
    print("Hora: HH:MM")
    print("Data: YYYY-MM-DD")
    print("CPF: 11 números\n")

    diagnostico = input("Diagnóstico: ")

    hora = validar_hora(input("Hora HH:MM: "))

    if not hora:
        print("Hora inválida.")
        return

    data = validar_data(input("Data YYYY-MM-DD: "))

    if not data:
        print("Data inválida.")
        return

    id_animal = input("ID animal: ")

    cursor.execute(
        "SELECT 1 FROM clinica.animal WHERE id_chave=%s",
        (id_animal,)
    )

    if not cursor.fetchone():
        print("Animal não existe.")
        return

    cpf = input("CPF veterinário: ")

    if not validar_cpf(cpf):
        print("CPF inválido.")
        return

    cpf = int(cpf)

    cursor.execute(
        "SELECT 1 FROM clinica.veterinario WHERE funcionario_cpf=%s",
        (cpf,)
    )

    if not cursor.fetchone():
        print("Veterinário não existe.")
        return

    cursor.execute("""
        INSERT INTO clinica.consulta
        (diagnostico, horario, data_consulta, id_animal, veterinario_cpf)
        VALUES (%s,%s,%s,%s,%s)
    """, (diagnostico, hora, data, id_animal, cpf))

    conex.commit()

    print("Inserido com sucesso.")

    cursor.close()
    conex.close()

#funções de deletar
def deletar_animal():
    conex = conexao()
    cursor = conex.cursor()

    id = input("ID animal: ")

    cursor.execute("DELETE FROM clinica.animal WHERE id_chave=%s", (id,))

    conex.commit()

    print("Deletado.")

    cursor.close()
    conex.close()

def deletar_veterinario():
    conex = conexao()
    cursor = conex.cursor()

    crmv = input("CRMV: ")

    cursor.execute(
        "DELETE FROM clinica.veterinario WHERE crmv=%s",
        (crmv,)
    )

    conex.commit()

    print("Deletado.")

    cursor.close()
    conex.close()

def deletar_consulta():
    conex = conexao()
    cursor = conex.cursor()

    id = input("ID consulta: ")

    cursor.execute(
        "DELETE FROM clinica.consulta WHERE id_consulta=%s",
        (id,)
    )

    conex.commit()

    print("Deletado.")

    cursor.close()
    conex.close()

#Funções de atualizar
def atualizar_animal():
    conex = conexao()
    cursor = conex.cursor()

    print("\nFORMATO ID: até 9 caracteres")

    id_chave = input("ID animal: ")
    cursor.execute(
        "SELECT * FROM clinica.animal WHERE id_chave=%s",
        (id_chave,)
    )

    if not cursor.fetchone():
        print("Animal não existe.")
        return

    print("\nO que deseja atualizar?")
    print("1 Nome")
    print("2 Espécie")
    print("3 Raça")
    print("4 CPF tutor")
    print("5 Data nascimento")
    print("6 Idade")

    op = input("Escolha: ")

    if op == "1":
        nome = input("Novo nome: ")
        cursor.execute("""
            UPDATE clinica.animal
            SET nome=%s
            WHERE id_chave=%s
        """, (nome, id_chave))

    elif op == "2":
        especie = input("Nova espécie: ")
        cursor.execute("""
            UPDATE clinica.animal
            SET especie=%s
            WHERE id_chave=%s
        """, (especie, id_chave))

    elif op == "3":
        raca = input("Nova raça: ")
        cursor.execute("""
            UPDATE clinica.animal
            SET raca=%s
            WHERE id_chave=%s
        """, (raca, id_chave))

    elif op == "4":
        print("Formato CPF: 11 números")
        cpf = input("Novo CPF: ")

        if not validar_cpf(cpf):
            print("CPF inválido.")
            return

        cpf = int(cpf)
        cursor.execute(
            "SELECT 1 FROM clinica.tutor WHERE tutor_cpf=%s",
            (cpf,)
        )
        if not cursor.fetchone():
            print("Tutor não existe.")
            return

        cursor.execute("""
            UPDATE clinica.animal
            SET tutor_cpf=%s
            WHERE id_chave=%s
        """, (cpf, id_chave))

    elif op == "5":
        print("Formato data: YYYY-MM-DD")

        data = validar_data(input("Nova data: "))
        if not data:
            print("Data inválida.")
            return

        cursor.execute("""
            UPDATE clinica.animal
            SET data_nascimento=%s
            WHERE id_chave=%s
        """, (data, id_chave))

    elif op == "6":
        idade = validar_int(input("Nova idade: "))
        if idade is None or idade < 0:
            print("Idade inválida.")
            return

        cursor.execute("""
            UPDATE clinica.animal
            SET idade=%s
            WHERE id_chave=%s
        """, (idade, id_chave))

    else:
        print("Opção inválida.")
        return
    
    conex.commit()

    print("Atualizado com sucesso.")

    cursor.close()
    conex.close()

def atualizar_veterinario():
    conex = conexao()
    cursor = conex.cursor()

    print("Formato CPF: 11 números")

    cpf = input("CPF veterinário: ")

    if not validar_cpf(cpf):
        print("CPF inválido.")
        return

    cpf = int(cpf)
    cursor.execute(
        "SELECT * FROM clinica.veterinario WHERE funcionario_cpf=%s",
        (cpf,)
    )

    if not cursor.fetchone():
        print("Veterinário não existe.")
        return

    print("\nO que deseja atualizar?")
    print("1 CRMV")
    print("2 Especialidade")

    op = input("Escolha: ")

    if op == "1":
        crmv = input("Novo CRMV: ")
        cursor.execute("""
            UPDATE clinica.veterinario
            SET crmv=%s
            WHERE funcionario_cpf=%s
        """, (crmv, cpf))


    elif op == "2":
        esp = input("Nova especialidade: ")
        cursor.execute("""
            UPDATE clinica.veterinario
            SET especialidade=%s
            WHERE funcionario_cpf=%s
        """, (esp, cpf))

    else:
        print("Opção inválida.")
        return


    conex.commit()

    print("Atualizado com sucesso.")

    cursor.close()
    conex.close()

def atualizar_consulta():
    conex = conexao()
    cursor = conex.cursor()

    print("Formato ID consulta: número")
    
    id = validar_int(input("ID consulta: "))

    if id is None:
        print("ID inválido.")
        return

    cursor.execute(
        "SELECT * FROM clinica.consulta WHERE id_consulta=%s",
        (id,)
    )

    if not cursor.fetchone():
        print("Consulta não existe.")
        return

    print("\nO que deseja atualizar?")
    print("1 Diagnóstico")
    print("2 Hora")
    print("3 Data")

    op = input("Escolha: ")

    if op == "1":
        d = input("Novo diagnóstico: ")
        cursor.execute("""
            UPDATE clinica.consulta
            SET diagnostico=%s
            WHERE id_consulta=%s
        """, (d, id))

    elif op == "2":
        print("Formato hora: HH:MM")

        h = validar_hora(input("Nova hora: "))

        if not h:
            print("Hora inválida.")
            return

        cursor.execute("""
            UPDATE clinica.consulta
            SET horario=%s
            WHERE id_consulta=%s
        """, (h, id))

    elif op == "3":
        print("Formato data: YYYY-MM-DD")

        data = validar_data(input("Nova data: "))

        if not data:
            print("Data inválida.")
            return

        cursor.execute("""
            UPDATE clinica.consulta
            SET data_consulta=%s
            WHERE id_consulta=%s
        """, (data, id))

    else:
        print("Opção inválida.")
        return


    conex.commit()

    print("Atualizado com sucesso.")

    cursor.close()
    conex.close()

#Loop principal 
while True:
    menu()

    op = input("Escolha: ")

    if op == "5":
        break

    print("\n1 Animal")
    print("2 Veterinário")
    print("3 Consulta")

    x = input("Escolha: ")

    if op == "1":
        if x == "1":
            inserir_animal()

        elif x == "2":
            inserir_veterinario()

        elif x == "3":
            inserir_consulta()

    elif op == "2":
        if x == "1":
            listar_animais()

        elif x == "2":
            listar_veterinarios()

        elif x == "3":
            listar_consultas()
    
    elif op == "3":
        if x == "1":
            atualizar_animal()

        elif x == "2":
            atualizar_veterinario()

        elif x == "3":
            atualizar_consulta()

    elif op == "4":
        if x == "1":
            deletar_animal()

        elif x == "2":
            deletar_veterinario()

        elif x == "3":
            deletar_consulta()
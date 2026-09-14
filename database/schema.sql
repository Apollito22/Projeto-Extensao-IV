-- 1. TABELA: USUARIOS

CREATE TABLE usuarios (
    id INTEGER PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    senha_hash VARCHAR(255) NOT NULL,
    perfil VARCHAR(20) NOT NULL DEFAULT 'aluno',
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_usuarios_perfil
        CHECK (perfil IN ('admin', 'editor', 'aluno'))
);

-- 2. TABELA: CATEGORIAS

CREATE TABLE categorias (
    id INTEGER PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    slug VARCHAR(150) NOT NULL UNIQUE,
    descricao TEXT,
    icone VARCHAR(255),
    ordem INTEGER NOT NULL DEFAULT 0,
    ativo BOOLEAN NOT NULL DEFAULT TRUE
);

-- 3. TABELA: CONTEUDOS

CREATE TABLE conteudos (
    id INTEGER PRIMARY KEY,
    titulo VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL UNIQUE,
    resumo TEXT,
    corpo TEXT NOT NULL,
    imagem_capa VARCHAR(500),
    link_youtube VARCHAR(500),
    categoria_id BIGINT NOT NULL,
    autor_id BIGINT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'rascunho',
    destaque BOOLEAN NOT NULL DEFAULT FALSE,
    publicado_em TIMESTAMP,

    CONSTRAINT fk_conteudos_categoria
        FOREIGN KEY (categoria_id)
        REFERENCES categorias(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_conteudos_autor
        FOREIGN KEY (autor_id)
        REFERENCES usuarios(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT chk_conteudos_status
        CHECK (status IN ('rascunho', 'publicado', 'arquivado'))
);

-- 4. TABELA: TAGS

CREATE TABLE tags (
    id INTEGER PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    slug VARCHAR(150) NOT NULL UNIQUE
);

-- 5. TABELA: CONTEUDO_TAGS

CREATE TABLE conteudo_tags (
    conteudo_id BIGINT NOT NULL,
    tag_id BIGINT NOT NULL,
    PRIMARY KEY (conteudo_id, tag_id),
    CONSTRAINT fk_conteudo_tags_conteudo
        FOREIGN KEY (conteudo_id)
        REFERENCES conteudos(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_conteudo_tags_tag
        FOREIGN KEY (tag_id)
        REFERENCES tags(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- 6. TABELA: EVENTOS

CREATE TABLE eventos (
    id INTEGER PRIMARY KEY,
    titulo VARCHAR(255) NOT NULL,
    descricao TEXT,
    data_inicio TIMESTAMP NOT NULL,
    data_fim TIMESTAMP,
    local VARCHAR(255),
    link_inscricao VARCHAR(500),
    autor_id BIGINT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'agendado',

    CONSTRAINT fk_eventos_autor
        FOREIGN KEY (autor_id)
        REFERENCES usuarios(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT chk_eventos_status
        CHECK (status IN ('agendado', 'realizado', 'cancelado')),

    CONSTRAINT chk_eventos_datas
        CHECK (data_fim IS NULL OR data_fim >= data_inicio)
);

-- 7. TABELA: MIDIAS

CREATE TABLE midias (
    id INTEGER PRIMARY KEY,
    nome_arquivo VARCHAR(255) NOT NULL,
    caminho VARCHAR(500) NOT NULL,
    tipo_mime VARCHAR(100) NOT NULL,
    tamanho_bytes BIGINT NOT NULL,
    enviado_por BIGINT NOT NULL,
    criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_midias_enviado_por
        FOREIGN KEY (enviado_por)
        REFERENCES usuarios(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT chk_midias_tamanho
        CHECK (tamanho_bytes >= 0)
);

-- 8. TABELA: AUDITORIA

CREATE TABLE auditoria (
    id INTEGER PRIMARY KEY,
    usuario_id BIGINT,
    acao VARCHAR(100) NOT NULL,
    tabela_afetada VARCHAR(100) NOT NULL,
    registro_id BIGINT,
    detalhes JSONB,
    ip_origem INET,
    criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_auditoria_usuario
        FOREIGN KEY (usuario_id)
        REFERENCES usuarios(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL
);

-- INDICES


CREATE INDEX idx_conteudos_categoria
    ON conteudos(categoria_id);

CREATE INDEX idx_conteudos_autor
    ON conteudos(autor_id);

CREATE INDEX idx_conteudos_status
    ON conteudos(status);

CREATE INDEX idx_conteudos_destaque
    ON conteudos(destaque);

CREATE INDEX idx_conteudos_publicado_em
    ON conteudos(publicado_em);

CREATE INDEX idx_conteudo_tags_tag
    ON conteudo_tags(tag_id);

CREATE INDEX idx_eventos_autor
    ON eventos(autor_id);

CREATE INDEX idx_eventos_data_inicio
    ON eventos(data_inicio);

CREATE INDEX idx_midias_enviado_por
    ON midias(enviado_por);

CREATE INDEX idx_auditoria_usuario
    ON auditoria(usuario_id);

CREATE INDEX idx_auditoria_criado_em
    ON auditoria(criado_em);
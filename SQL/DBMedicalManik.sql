PGDMP  	                    |            medicalmanik    16.3    16.3 I    m           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            n           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            o           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            p           1262    16397    medicalmanik    DATABASE     �   CREATE DATABASE medicalmanik WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'Spanish_Spain.1252' TABLESPACE = ts_medimanik;
    DROP DATABASE medicalmanik;
                postgres    false            �            1259    24648    asistente_consultorio    TABLE     d   CREATE TABLE public.asistente_consultorio (
    asistente_id integer,
    consultorio_id integer
);
 )   DROP TABLE public.asistente_consultorio;
       public         heap    postgres    false            �            1259    16400    consultorio    TABLE       CREATE TABLE public.consultorio (
    id integer NOT NULL,
    nombre character varying(64) NOT NULL,
    direccion character varying(128) NOT NULL,
    colonia_id integer,
    costo integer DEFAULT 0,
    telefono character varying(64) NOT NULL,
    status character(1) DEFAULT '1'::bpchar,
    pais_id integer,
    intervalo character varying(3),
    ultimo_utilizado timestamp without time zone,
    zona_horaria character varying(128),
    tipo_personal integer,
    clue_id integer,
    usuario_id integer
);
    DROP TABLE public.consultorio;
       public         heap    postgres    false            �            1259    16419    evento    TABLE     f  CREATE TABLE public.evento (
    id bigint NOT NULL,
    token character varying(40) NOT NULL,
    nombre character varying(150) NOT NULL,
    descripcion character varying(400),
    fecha_inicio timestamp with time zone NOT NULL,
    fecha_fin timestamp with time zone NOT NULL,
    all_day boolean DEFAULT false,
    usuario_id bigint NOT NULL,
    calendario_id bigint NOT NULL,
    status character varying(12) DEFAULT 'EN_ESPERA'::character varying NOT NULL,
    fecha_registro timestamp with time zone DEFAULT now() NOT NULL,
    zona_horaria character varying(100),
    tipo_evento character varying(20)
);
    DROP TABLE public.evento;
       public         heap    postgres    false            �            1259    32848    grupo    TABLE     c   CREATE TABLE public.grupo (
    id integer NOT NULL,
    nombre character varying(255) NOT NULL
);
    DROP TABLE public.grupo;
       public         heap    postgres    false            �            1259    41044    grupo_asistente    TABLE     j   CREATE TABLE public.grupo_asistente (
    grupo_id integer NOT NULL,
    asistente_id integer NOT NULL
);
 #   DROP TABLE public.grupo_asistente;
       public         heap    postgres    false            �            1259    41059    grupo_consultorio    TABLE     n   CREATE TABLE public.grupo_consultorio (
    grupo_id integer NOT NULL,
    consultorio_id integer NOT NULL
);
 %   DROP TABLE public.grupo_consultorio;
       public         heap    postgres    false            �            1259    41089    grupo_enfermero    TABLE     j   CREATE TABLE public.grupo_enfermero (
    grupo_id integer NOT NULL,
    enfermero_id integer NOT NULL
);
 #   DROP TABLE public.grupo_enfermero;
       public         heap    postgres    false            �            1259    41029    grupo_medico    TABLE     d   CREATE TABLE public.grupo_medico (
    grupo_id integer NOT NULL,
    medico_id integer NOT NULL
);
     DROP TABLE public.grupo_medico;
       public         heap    postgres    false            �            1259    41074    grupo_paciente    TABLE     h   CREATE TABLE public.grupo_paciente (
    grupo_id integer NOT NULL,
    paciente_id integer NOT NULL
);
 "   DROP TABLE public.grupo_paciente;
       public         heap    postgres    false            �            1259    16407    horario_consultorio    TABLE     >  CREATE TABLE public.horario_consultorio (
    id integer NOT NULL,
    lunes character varying(256),
    martes character varying(256),
    miercoles character varying(256),
    jueves character varying(256),
    viernes character varying(256),
    sabado character varying(256),
    domingo character varying(256)
);
 '   DROP TABLE public.horario_consultorio;
       public         heap    postgres    false            �            1259    41105    lista_espera    TABLE     {  CREATE TABLE public.lista_espera (
    id bigint NOT NULL,
    token character varying(40) NOT NULL,
    nombre character varying(150) NOT NULL,
    descripcion character varying(500),
    fecha_solicitud timestamp with time zone DEFAULT now() NOT NULL,
    fecha_inicio timestamp with time zone NOT NULL,
    fecha_fin timestamp with time zone NOT NULL,
    calendario_id bigint NOT NULL,
    color character varying(11),
    status character varying(12) DEFAULT 'EN_ESPERA'::character varying NOT NULL,
    motivo_consulta character varying(25),
    tipo_cita character varying(25),
    asignado_id bigint,
    paciente_id bigint
);
     DROP TABLE public.lista_espera;
       public         heap    postgres    false            �            1259    41104    lista_espera_id_seq    SEQUENCE     |   CREATE SEQUENCE public.lista_espera_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.lista_espera_id_seq;
       public          postgres    false    231            q           0    0    lista_espera_id_seq    SEQUENCE OWNED BY     K   ALTER SEQUENCE public.lista_espera_id_seq OWNED BY public.lista_espera.id;
          public          postgres    false    230            �            1259    16438    paciente    TABLE       CREATE TABLE public.paciente (
    id integer NOT NULL,
    nombre character varying(32) NOT NULL,
    ap_paterno character varying(64),
    ap_materno character varying(64),
    fecha_nacimiento date,
    sexo character(1) DEFAULT 'F'::bpchar NOT NULL,
    colonia_id integer,
    telefono_movil character varying(20),
    telefono_fijo character varying(20),
    correo character varying(64),
    avatar text,
    fecha_registro timestamp with time zone,
    direccion character varying(256),
    identificador character varying(18),
    curp character varying(18),
    codigo_postal integer,
    municipio_id integer,
    estado_id integer,
    pais character varying(2),
    pais_id integer,
    entidad_nacimiento_id character varying(2),
    genero_id integer,
    consultorio_id integer
);
    DROP TABLE public.paciente;
       public         heap    postgres    false            �            1259    32823    roles_permisos    TABLE     �  CREATE TABLE public.roles_permisos (
    id integer NOT NULL,
    rol character varying(10) NOT NULL,
    captura_signos_vitales boolean DEFAULT false,
    captura_antecedentes_clinicos boolean DEFAULT false,
    agendar_citas_eventos boolean DEFAULT false,
    crear_pacientes boolean DEFAULT false,
    editar_pacientes boolean DEFAULT false,
    eliminar_pacientes boolean DEFAULT false
);
 "   DROP TABLE public.roles_permisos;
       public         heap    postgres    false            �            1259    32822    roles_permisos_id_seq    SEQUENCE     �   CREATE SEQUENCE public.roles_permisos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE public.roles_permisos_id_seq;
       public          postgres    false    223            r           0    0    roles_permisos_id_seq    SEQUENCE OWNED BY     O   ALTER SEQUENCE public.roles_permisos_id_seq OWNED BY public.roles_permisos.id;
          public          postgres    false    222            �            1259    41116    tarea_id_seq    SEQUENCE     u   CREATE SEQUENCE public.tarea_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 #   DROP SEQUENCE public.tarea_id_seq;
       public          postgres    false            �            1259    16429    tarea    TABLE     �  CREATE TABLE public.tarea (
    id bigint DEFAULT nextval('public.tarea_id_seq'::regclass) NOT NULL,
    token character varying(40) NOT NULL,
    nombre character varying(150) NOT NULL,
    descripcion character varying(500),
    fecha_inicio timestamp with time zone NOT NULL,
    fecha_fin timestamp with time zone NOT NULL,
    calendario_id bigint NOT NULL,
    color character varying(11),
    status character varying(12) DEFAULT 'EN_ESP
ERA'::character varying NOT NULL,
    fecha_registro timestamp with time zone DEFAULT now() NOT NULL,
    asignado_id bigint NOT NULL,
    paciente_id bigint,
    motivo_consulta character varying(25),
    tipo_cita character varying(25)
);
    DROP TABLE public.tarea;
       public         heap    postgres    false    232            �            1259    16446    usuario    TABLE     �  CREATE TABLE public.usuario (
    id integer NOT NULL,
    correo character varying(64) NOT NULL,
    contrasena character varying(64) NOT NULL,
    rol character varying(3) NOT NULL,
    nombre character varying(32) NOT NULL,
    apellidos character varying(64) NOT NULL,
    telefono_movil character varying(20),
    telefono_fijo character varying(20),
    direccion character varying(256),
    status character(1) NOT NULL,
    ultimo_acceso timestamp with time zone DEFAULT now(),
    ultimo_cambio timestamp with time zone DEFAULT now(),
    fecha_creacion timestamp with time zone NOT NULL,
    fecha_activacion timestamp with time zone,
    avatar text,
    cuenta_id integer DEFAULT 1,
    sexo character(1),
    fecha_nacimiento date,
    zona_horaria_vigencia character varying(128),
    user_microservice_id bigint,
    prefijo character varying(6) DEFAULT NULL::character varying
);
    DROP TABLE public.usuario;
       public         heap    postgres    false            s           0    0    COLUMN usuario.rol    COMMENT     F   COMMENT ON COLUMN public.usuario.rol IS 'MED=Médico, ASI=Asistente';
          public          postgres    false    220            t           0    0    COLUMN usuario.status    COMMENT     D   COMMENT ON COLUMN public.usuario.status IS '0=No activo, 1=Activo';
          public          postgres    false    220            �           2604    41108    lista_espera id    DEFAULT     r   ALTER TABLE ONLY public.lista_espera ALTER COLUMN id SET DEFAULT nextval('public.lista_espera_id_seq'::regclass);
 >   ALTER TABLE public.lista_espera ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    231    230    231            �           2604    32826    roles_permisos id    DEFAULT     v   ALTER TABLE ONLY public.roles_permisos ALTER COLUMN id SET DEFAULT nextval('public.roles_permisos_id_seq'::regclass);
 @   ALTER TABLE public.roles_permisos ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    222    223    223            _          0    24648    asistente_consultorio 
   TABLE DATA           M   COPY public.asistente_consultorio (asistente_id, consultorio_id) FROM stdin;
    public          postgres    false    221   �h       Y          0    16400    consultorio 
   TABLE DATA           �   COPY public.consultorio (id, nombre, direccion, colonia_id, costo, telefono, status, pais_id, intervalo, ultimo_utilizado, zona_horaria, tipo_personal, clue_id, usuario_id) FROM stdin;
    public          postgres    false    215   �h       [          0    16419    evento 
   TABLE DATA           �   COPY public.evento (id, token, nombre, descripcion, fecha_inicio, fecha_fin, all_day, usuario_id, calendario_id, status, fecha_registro, zona_horaria, tipo_evento) FROM stdin;
    public          postgres    false    217   7i       b          0    32848    grupo 
   TABLE DATA           +   COPY public.grupo (id, nombre) FROM stdin;
    public          postgres    false    224   �i       d          0    41044    grupo_asistente 
   TABLE DATA           A   COPY public.grupo_asistente (grupo_id, asistente_id) FROM stdin;
    public          postgres    false    226   �i       e          0    41059    grupo_consultorio 
   TABLE DATA           E   COPY public.grupo_consultorio (grupo_id, consultorio_id) FROM stdin;
    public          postgres    false    227   �i       g          0    41089    grupo_enfermero 
   TABLE DATA           A   COPY public.grupo_enfermero (grupo_id, enfermero_id) FROM stdin;
    public          postgres    false    229   #j       c          0    41029    grupo_medico 
   TABLE DATA           ;   COPY public.grupo_medico (grupo_id, medico_id) FROM stdin;
    public          postgres    false    225   Dj       f          0    41074    grupo_paciente 
   TABLE DATA           ?   COPY public.grupo_paciente (grupo_id, paciente_id) FROM stdin;
    public          postgres    false    228   nj       Z          0    16407    horario_consultorio 
   TABLE DATA           m   COPY public.horario_consultorio (id, lunes, martes, miercoles, jueves, viernes, sabado, domingo) FROM stdin;
    public          postgres    false    216   �j       i          0    41105    lista_espera 
   TABLE DATA           �   COPY public.lista_espera (id, token, nombre, descripcion, fecha_solicitud, fecha_inicio, fecha_fin, calendario_id, color, status, motivo_consulta, tipo_cita, asignado_id, paciente_id) FROM stdin;
    public          postgres    false    231   @k       ]          0    16438    paciente 
   TABLE DATA           2  COPY public.paciente (id, nombre, ap_paterno, ap_materno, fecha_nacimiento, sexo, colonia_id, telefono_movil, telefono_fijo, correo, avatar, fecha_registro, direccion, identificador, curp, codigo_postal, municipio_id, estado_id, pais, pais_id, entidad_nacimiento_id, genero_id, consultorio_id) FROM stdin;
    public          postgres    false    219   ]k       a          0    32823    roles_permisos 
   TABLE DATA           �   COPY public.roles_permisos (id, rol, captura_signos_vitales, captura_antecedentes_clinicos, agendar_citas_eventos, crear_pacientes, editar_pacientes, eliminar_pacientes) FROM stdin;
    public          postgres    false    223   �p       \          0    16429    tarea 
   TABLE DATA           �   COPY public.tarea (id, token, nombre, descripcion, fecha_inicio, fecha_fin, calendario_id, color, status, fecha_registro, asignado_id, paciente_id, motivo_consulta, tipo_cita) FROM stdin;
    public          postgres    false    218   ,q       ^          0    16446    usuario 
   TABLE DATA           $  COPY public.usuario (id, correo, contrasena, rol, nombre, apellidos, telefono_movil, telefono_fijo, direccion, status, ultimo_acceso, ultimo_cambio, fecha_creacion, fecha_activacion, avatar, cuenta_id, sexo, fecha_nacimiento, zona_horaria_vigencia, user_microservice_id, prefijo) FROM stdin;
    public          postgres    false    220   �q       u           0    0    lista_espera_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.lista_espera_id_seq', 1, false);
          public          postgres    false    230            v           0    0    roles_permisos_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.roles_permisos_id_seq', 1, false);
          public          postgres    false    222            w           0    0    tarea_id_seq    SEQUENCE SET     :   SELECT pg_catalog.setval('public.tarea_id_seq', 1, true);
          public          postgres    false    232            �           2606    16406    consultorio consultorio_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.consultorio
    ADD CONSTRAINT consultorio_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.consultorio DROP CONSTRAINT consultorio_pkey;
       public            postgres    false    215            �           2606    16428    evento evento_pkey 
   CONSTRAINT     P   ALTER TABLE ONLY public.evento
    ADD CONSTRAINT evento_pkey PRIMARY KEY (id);
 <   ALTER TABLE ONLY public.evento DROP CONSTRAINT evento_pkey;
       public            postgres    false    217            �           2606    41048 $   grupo_asistente grupo_asistente_pkey 
   CONSTRAINT     v   ALTER TABLE ONLY public.grupo_asistente
    ADD CONSTRAINT grupo_asistente_pkey PRIMARY KEY (grupo_id, asistente_id);
 N   ALTER TABLE ONLY public.grupo_asistente DROP CONSTRAINT grupo_asistente_pkey;
       public            postgres    false    226    226            �           2606    41063 (   grupo_consultorio grupo_consultorio_pkey 
   CONSTRAINT     |   ALTER TABLE ONLY public.grupo_consultorio
    ADD CONSTRAINT grupo_consultorio_pkey PRIMARY KEY (grupo_id, consultorio_id);
 R   ALTER TABLE ONLY public.grupo_consultorio DROP CONSTRAINT grupo_consultorio_pkey;
       public            postgres    false    227    227            �           2606    41093 $   grupo_enfermero grupo_enfermero_pkey 
   CONSTRAINT     v   ALTER TABLE ONLY public.grupo_enfermero
    ADD CONSTRAINT grupo_enfermero_pkey PRIMARY KEY (grupo_id, enfermero_id);
 N   ALTER TABLE ONLY public.grupo_enfermero DROP CONSTRAINT grupo_enfermero_pkey;
       public            postgres    false    229    229            �           2606    41033    grupo_medico grupo_medico_pkey 
   CONSTRAINT     m   ALTER TABLE ONLY public.grupo_medico
    ADD CONSTRAINT grupo_medico_pkey PRIMARY KEY (grupo_id, medico_id);
 H   ALTER TABLE ONLY public.grupo_medico DROP CONSTRAINT grupo_medico_pkey;
       public            postgres    false    225    225            �           2606    41078 "   grupo_paciente grupo_paciente_pkey 
   CONSTRAINT     s   ALTER TABLE ONLY public.grupo_paciente
    ADD CONSTRAINT grupo_paciente_pkey PRIMARY KEY (grupo_id, paciente_id);
 L   ALTER TABLE ONLY public.grupo_paciente DROP CONSTRAINT grupo_paciente_pkey;
       public            postgres    false    228    228            �           2606    32852    grupo grupo_pkey 
   CONSTRAINT     N   ALTER TABLE ONLY public.grupo
    ADD CONSTRAINT grupo_pkey PRIMARY KEY (id);
 :   ALTER TABLE ONLY public.grupo DROP CONSTRAINT grupo_pkey;
       public            postgres    false    224            �           2606    16413 ,   horario_consultorio horario_consultorio_pkey 
   CONSTRAINT     j   ALTER TABLE ONLY public.horario_consultorio
    ADD CONSTRAINT horario_consultorio_pkey PRIMARY KEY (id);
 V   ALTER TABLE ONLY public.horario_consultorio DROP CONSTRAINT horario_consultorio_pkey;
       public            postgres    false    216            �           2606    41115    lista_espera lista_espera_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.lista_espera
    ADD CONSTRAINT lista_espera_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.lista_espera DROP CONSTRAINT lista_espera_pkey;
       public            postgres    false    231            �           2606    16445    paciente paciente_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.paciente
    ADD CONSTRAINT paciente_pkey PRIMARY KEY (id);
 @   ALTER TABLE ONLY public.paciente DROP CONSTRAINT paciente_pkey;
       public            postgres    false    219            �           2606    32834 "   roles_permisos roles_permisos_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.roles_permisos
    ADD CONSTRAINT roles_permisos_pkey PRIMARY KEY (id);
 L   ALTER TABLE ONLY public.roles_permisos DROP CONSTRAINT roles_permisos_pkey;
       public            postgres    false    223            �           2606    16437    tarea tarea_pkey 
   CONSTRAINT     N   ALTER TABLE ONLY public.tarea
    ADD CONSTRAINT tarea_pkey PRIMARY KEY (id);
 :   ALTER TABLE ONLY public.tarea DROP CONSTRAINT tarea_pkey;
       public            postgres    false    218            �           2606    32847    usuario usuario_pkey 
   CONSTRAINT     R   ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_pkey PRIMARY KEY (id);
 >   ALTER TABLE ONLY public.usuario DROP CONSTRAINT usuario_pkey;
       public            postgres    false    220            �           2606    24651 :   asistente_consultorio asistente_consultorio_consultorio_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.asistente_consultorio
    ADD CONSTRAINT asistente_consultorio_consultorio_fk FOREIGN KEY (consultorio_id) REFERENCES public.consultorio(id);
 d   ALTER TABLE ONLY public.asistente_consultorio DROP CONSTRAINT asistente_consultorio_consultorio_fk;
       public          postgres    false    215    221    4770            �           2606    32873    paciente fk_consultorio    FK CONSTRAINT     �   ALTER TABLE ONLY public.paciente
    ADD CONSTRAINT fk_consultorio FOREIGN KEY (consultorio_id) REFERENCES public.consultorio(id);
 A   ALTER TABLE ONLY public.paciente DROP CONSTRAINT fk_consultorio;
       public          postgres    false    219    215    4770            �           2606    41054 1   grupo_asistente grupo_asistente_asistente_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.grupo_asistente
    ADD CONSTRAINT grupo_asistente_asistente_id_fkey FOREIGN KEY (asistente_id) REFERENCES public.usuario(id);
 [   ALTER TABLE ONLY public.grupo_asistente DROP CONSTRAINT grupo_asistente_asistente_id_fkey;
       public          postgres    false    4780    226    220            �           2606    41049 -   grupo_asistente grupo_asistente_grupo_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.grupo_asistente
    ADD CONSTRAINT grupo_asistente_grupo_id_fkey FOREIGN KEY (grupo_id) REFERENCES public.grupo(id);
 W   ALTER TABLE ONLY public.grupo_asistente DROP CONSTRAINT grupo_asistente_grupo_id_fkey;
       public          postgres    false    224    226    4784            �           2606    41069 7   grupo_consultorio grupo_consultorio_consultorio_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.grupo_consultorio
    ADD CONSTRAINT grupo_consultorio_consultorio_id_fkey FOREIGN KEY (consultorio_id) REFERENCES public.consultorio(id);
 a   ALTER TABLE ONLY public.grupo_consultorio DROP CONSTRAINT grupo_consultorio_consultorio_id_fkey;
       public          postgres    false    4770    215    227            �           2606    41064 1   grupo_consultorio grupo_consultorio_grupo_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.grupo_consultorio
    ADD CONSTRAINT grupo_consultorio_grupo_id_fkey FOREIGN KEY (grupo_id) REFERENCES public.grupo(id);
 [   ALTER TABLE ONLY public.grupo_consultorio DROP CONSTRAINT grupo_consultorio_grupo_id_fkey;
       public          postgres    false    227    224    4784            �           2606    41099 1   grupo_enfermero grupo_enfermero_enfermero_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.grupo_enfermero
    ADD CONSTRAINT grupo_enfermero_enfermero_id_fkey FOREIGN KEY (enfermero_id) REFERENCES public.usuario(id);
 [   ALTER TABLE ONLY public.grupo_enfermero DROP CONSTRAINT grupo_enfermero_enfermero_id_fkey;
       public          postgres    false    4780    229    220            �           2606    41094 -   grupo_enfermero grupo_enfermero_grupo_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.grupo_enfermero
    ADD CONSTRAINT grupo_enfermero_grupo_id_fkey FOREIGN KEY (grupo_id) REFERENCES public.grupo(id);
 W   ALTER TABLE ONLY public.grupo_enfermero DROP CONSTRAINT grupo_enfermero_grupo_id_fkey;
       public          postgres    false    224    4784    229            �           2606    41034 '   grupo_medico grupo_medico_grupo_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.grupo_medico
    ADD CONSTRAINT grupo_medico_grupo_id_fkey FOREIGN KEY (grupo_id) REFERENCES public.grupo(id);
 Q   ALTER TABLE ONLY public.grupo_medico DROP CONSTRAINT grupo_medico_grupo_id_fkey;
       public          postgres    false    224    225    4784            �           2606    41039 (   grupo_medico grupo_medico_medico_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.grupo_medico
    ADD CONSTRAINT grupo_medico_medico_id_fkey FOREIGN KEY (medico_id) REFERENCES public.usuario(id);
 R   ALTER TABLE ONLY public.grupo_medico DROP CONSTRAINT grupo_medico_medico_id_fkey;
       public          postgres    false    220    225    4780            �           2606    41079 +   grupo_paciente grupo_paciente_grupo_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.grupo_paciente
    ADD CONSTRAINT grupo_paciente_grupo_id_fkey FOREIGN KEY (grupo_id) REFERENCES public.grupo(id);
 U   ALTER TABLE ONLY public.grupo_paciente DROP CONSTRAINT grupo_paciente_grupo_id_fkey;
       public          postgres    false    224    228    4784            �           2606    41084 .   grupo_paciente grupo_paciente_paciente_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.grupo_paciente
    ADD CONSTRAINT grupo_paciente_paciente_id_fkey FOREIGN KEY (paciente_id) REFERENCES public.paciente(id);
 X   ALTER TABLE ONLY public.grupo_paciente DROP CONSTRAINT grupo_paciente_paciente_id_fkey;
       public          postgres    false    4778    228    219            �           2606    16414 /   horario_consultorio horario_consultorio_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.horario_consultorio
    ADD CONSTRAINT horario_consultorio_id_fkey FOREIGN KEY (id) REFERENCES public.consultorio(id) ON UPDATE CASCADE ON DELETE CASCADE;
 Y   ALTER TABLE ONLY public.horario_consultorio DROP CONSTRAINT horario_consultorio_id_fkey;
       public          postgres    false    4770    216    215            _      x�3�4�2�=... ��      Y   y   x�m�K�0E���*��$!�`�DeR���ߠ�?�d=��.�&��"X���9F��̶�c�u�AC%Aڿ �dq�SY�s�_���|0�ך���u�s(�~�,�;�9cCD'�.�      [   h   x�3�4�L-K�+�O��4202�5��52R0��20 "]3��������%��K8́�]��]�\�Q�X�[��ZZ�U��q�&�&�-K����� ���      b      x�3�L/*-�7�2�0��b���� Or�      d      x�3�4�2������ L�      e      x�3�4�2�4����� ��      g      x�3������� �%      c      x�3�4�2�4�2�44������ 5B      f      x�3�4�2�4����� ��      Z   �   x��A
� E��)z��8&������y+�!��"�C��A=�����\�X��8x<����v8�	^�^��p&�>���7x��t<Oǳs�5���ͬ4��$5�X���xu�h����{՜u�xf}�M���o�2:[+�������O3� �� �      i      x������ � �      ]   �  x��V�r�H>��B��fF�?N�m�Cf���l�2 �B�J@���Qr�CNy^l{$��.q�)�bʨ{�o���,`��a~���0��CМ)_+�h��4~��x���}��]�n�6q�β�}�O�CD�zm浈������e)����, )c���?���t7���3��E�Q���
����PJ��� ���ڜ�}Q(�˥D ���IL
�m���<���dO�<1�5�i�kP�z�'������T���j)0��C5_��]qX-`1�%����4�3΅�s�c^�? !*�T�}uvەxyy��/`e�eh��ˤ딘��]ybL{�2�S�s	�}�B`�͕K5m`hEW��W4�ci�w����<^ �S��}��{>G$K�a��g�4�UJ����(R�L~�j����×��>��×4�%Պ�#g	����R�I���H���g�~J��A��!X1X�.�R�(oL�DΝI
�`�ߜ�,���87Q��3�Fv݇�@q"���C���K@�`�>n��A�4f͓�p�d�F�l��HG�A>V-Y()x��=$9+í��N���84�8�g��8��4��M��nV�3��N����˔��#f�@�ls�/�4J ����ȩ_62
�Z��<�y�@Xy�³���hw�aq�VN��6�v&��߻81BlHM�9�T
َ�b�E���є\)�:R�,%
�,_DN0�B,���tM>��H��c�B�JƼ�Z��ws��m��H��7N%�$K�0���m%j�۞TD^�$����Hɷ���&�g6I��M�M��g�������m���f�ம>��U�	!%<�9�Ŷ��_i���I4�"K���P.K��a4Ҝx���*?s"�-1�16E�9A��dL�fK�T�RDb̢*�Iev�V���X^�pS����*��D���z��"þjx]GIb��#/[�� ۊE��ѺřQ��;|K�
���6�&N��Ga�
�mQ�Y��*,e[g6ޝՁo"ut�~l}ʄ�;�(7aݪ�,��`2P�PJj�X]�򌗴�8��&uFf�T��ok�g��d���$�W���J�h�
C��׿���-�������pߴT�a��-ꨐWW�:c�,�~0��m'H��A��4���V���n.ν��~Z�	�u�&V����cg
��,*�s�8)N?x�4נ3좷�(�_�>��-E	Gf��I�]�f}�jm�grk�
��~����*����8�	�ܬ�;���r�G&Y�Iܰ���^3������z�H����9���R�k���q0t��C�o^�O�����?��k�(���T�-���>�
�1�o<x�#�ͽ6��mg���	��y�p3�_�+7�����տ���      a   +   x�3�t�s�,�4�2��uu�@!�!�c�'X&���� (z      \   �   x��н
�@ �9�疻$=���:������R+ԟ�����JL2�$|D�o}�9�Y�)2R���������!��֋�.��f�am�fB���Sw��e�?6��n�]`�v�j\��	�����4�i�Q�~�40��K���nS�}ݹꛑ�aL�H�����:B< �X�      ^     x����n1���S�byf�g�'��@*�^�f�Z���I*���Yx1��nv�Fɧ��og����իv�5�Hly��-��7k����vy�x��@9zf
dAZ��4�hLOO���S�$�����o��3A������{��;��{�*ܺ���	�"XIV%��S�((+�J�A`��X�{vg�q�s�k�vۛ�X���Yix��Iv]O/��utwγ��7���#������L��,�)�-lہ�"l6��0j����R�v%���W�E*2�̓�i�|34���4�_?��T�z��^C�kLF��`As%5�C�p�pQ���Iyh���m���:ܬX�%�ڢ権�V�4��8��Cd�\��F���b2�T$(bun�6�m��ҭW������/����z�3�2J9T��!�Ëu��r ئY��[��c`���=f�f��0\� ���4EXZ�� �� ��@�Cs�����m�fH9k�W:�@�z������!��K>�L~<i�Y     
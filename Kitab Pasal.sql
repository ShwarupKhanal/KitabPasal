PGDMP  1    :                |         	   BookStore    16.3    16.3 $               0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false                       0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false                       0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false                       1262    16672 	   BookStore    DATABASE     �   CREATE DATABASE "BookStore" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'English_United States.1252';
    DROP DATABASE "BookStore";
                postgres    false            �            1259    16828    library    TABLE     �   CREATE TABLE public.library (
    id integer NOT NULL,
    user_id integer,
    product_id integer,
    added_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);
    DROP TABLE public.library;
       public         heap    postgres    false            �            1259    16827    library_id_seq    SEQUENCE     �   CREATE SEQUENCE public.library_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE public.library_id_seq;
       public          postgres    false    222                       0    0    library_id_seq    SEQUENCE OWNED BY     A   ALTER SEQUENCE public.library_id_seq OWNED BY public.library.id;
          public          postgres    false    221            �            1259    16673    products    TABLE       CREATE TABLE public.products (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    price numeric(10,2) NOT NULL,
    image_url character varying(255),
    category character varying(255) DEFAULT NULL::character varying,
    pdf_url text
);
    DROP TABLE public.products;
       public         heap    postgres    false            �            1259    16678    products_id_seq    SEQUENCE     �   CREATE SEQUENCE public.products_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public.products_id_seq;
       public          postgres    false    215                       0    0    products_id_seq    SEQUENCE OWNED BY     C   ALTER SEQUENCE public.products_id_seq OWNED BY public.products.id;
          public          postgres    false    216            �            1259    16813    reviews    TABLE     �   CREATE TABLE public.reviews (
    id integer NOT NULL,
    product_id integer,
    reviewer_name character varying(100),
    review_text text,
    review_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);
    DROP TABLE public.reviews;
       public         heap    postgres    false            �            1259    16812    reviews_id_seq    SEQUENCE     �   CREATE SEQUENCE public.reviews_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE public.reviews_id_seq;
       public          postgres    false    220                       0    0    reviews_id_seq    SEQUENCE OWNED BY     A   ALTER SEQUENCE public.reviews_id_seq OWNED BY public.reviews.id;
          public          postgres    false    219            �            1259    16679    users    TABLE     �   CREATE TABLE public.users (
    id integer NOT NULL,
    fname character varying(100) NOT NULL,
    email character varying(100) NOT NULL,
    password character varying(100) NOT NULL
);
    DROP TABLE public.users;
       public         heap    postgres    false            �            1259    16682    users_id_seq    SEQUENCE     �   CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 #   DROP SEQUENCE public.users_id_seq;
       public          postgres    false    217                       0    0    users_id_seq    SEQUENCE OWNED BY     =   ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;
          public          postgres    false    218            d           2604    16831 
   library id    DEFAULT     h   ALTER TABLE ONLY public.library ALTER COLUMN id SET DEFAULT nextval('public.library_id_seq'::regclass);
 9   ALTER TABLE public.library ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    222    221    222            _           2604    16683    products id    DEFAULT     j   ALTER TABLE ONLY public.products ALTER COLUMN id SET DEFAULT nextval('public.products_id_seq'::regclass);
 :   ALTER TABLE public.products ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    216    215            b           2604    16816 
   reviews id    DEFAULT     h   ALTER TABLE ONLY public.reviews ALTER COLUMN id SET DEFAULT nextval('public.reviews_id_seq'::regclass);
 9   ALTER TABLE public.reviews ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    219    220    220            a           2604    16684    users id    DEFAULT     d   ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);
 7   ALTER TABLE public.users ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    218    217            	          0    16828    library 
   TABLE DATA           F   COPY public.library (id, user_id, product_id, added_date) FROM stdin;
    public          postgres    false    222   >'                 0    16673    products 
   TABLE DATA           ^   COPY public.products (id, name, description, price, image_url, category, pdf_url) FROM stdin;
    public          postgres    false    215   �'                 0    16813    reviews 
   TABLE DATA           Z   COPY public.reviews (id, product_id, reviewer_name, review_text, review_date) FROM stdin;
    public          postgres    false    220   M1                 0    16679    users 
   TABLE DATA           ;   COPY public.users (id, fname, email, password) FROM stdin;
    public          postgres    false    217   "2                  0    0    library_id_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('public.library_id_seq', 7, true);
          public          postgres    false    221                       0    0    products_id_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public.products_id_seq', 19, true);
          public          postgres    false    216                       0    0    reviews_id_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('public.reviews_id_seq', 6, true);
          public          postgres    false    219                       0    0    users_id_seq    SEQUENCE SET     :   SELECT pg_catalog.setval('public.users_id_seq', 5, true);
          public          postgres    false    218            o           2606    16834    library library_pkey 
   CONSTRAINT     R   ALTER TABLE ONLY public.library
    ADD CONSTRAINT library_pkey PRIMARY KEY (id);
 >   ALTER TABLE ONLY public.library DROP CONSTRAINT library_pkey;
       public            postgres    false    222            g           2606    16686    products products_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);
 @   ALTER TABLE ONLY public.products DROP CONSTRAINT products_pkey;
       public            postgres    false    215            m           2606    16821    reviews reviews_pkey 
   CONSTRAINT     R   ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_pkey PRIMARY KEY (id);
 >   ALTER TABLE ONLY public.reviews DROP CONSTRAINT reviews_pkey;
       public            postgres    false    220            i           2606    16688    users users_email_key 
   CONSTRAINT     Q   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);
 ?   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key;
       public            postgres    false    217            k           2606    16690    users users_pkey 
   CONSTRAINT     N   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);
 :   ALTER TABLE ONLY public.users DROP CONSTRAINT users_pkey;
       public            postgres    false    217            q           2606    16840    library library_product_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.library
    ADD CONSTRAINT library_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);
 I   ALTER TABLE ONLY public.library DROP CONSTRAINT library_product_id_fkey;
       public          postgres    false    4711    215    222            r           2606    16835    library library_user_id_fkey    FK CONSTRAINT     {   ALTER TABLE ONLY public.library
    ADD CONSTRAINT library_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);
 F   ALTER TABLE ONLY public.library DROP CONSTRAINT library_user_id_fkey;
       public          postgres    false    4715    222    217            p           2606    16822    reviews reviews_product_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);
 I   ALTER TABLE ONLY public.reviews DROP CONSTRAINT reviews_product_id_fkey;
       public          postgres    false    215    4711    220            	   m   x�}��C1Dѵ�"<��1�Z���Ni�Gs1b`��?���{��R�@�����&W`Z�����Z#95�r��[���+(�}�g�7�G�y�-"[kG4Q�f"� �f*t         �	  x��X�n�]����"�����m`H���ǲ���I ���.Z�b�du�����|I�%K�-[Ό�d1���q��{�����L��?,۳��F�.��F���~ȸv��֦�w��ϥdW�9����p�B�vçL9�Yc��*�Z�Y^r����f'5�%�LH�����\�����ʸ��V2S�t��Q.k��={�:����/Ć+�c������K�m�i�h����+Ss�p�+�dn*�`��[��TM�j�bQu�<�\q�x-���q��<l��~��X�{i���W��C��B�\�JH���6Q]�[�{BY�S�= ?*��[��]�l+^3�(����1������+�ma�_��'b��v��I����C;d��GB6�$��<��(���;9,�8I���{6�t]7�T�aX6(*=�E=q�i&�5�ͽ���o?</��������ۛ�߯7�4I���.���}����t�I��|5���S�l6�����y�����?~���{�x��P��]Yt[�W{W�**.�1B��.��������+Q-
���x{(�����̫JFH]w
]t�� �j�1{��x(\_`4�k�*�g��o���Tq(��m�ó./eE��  ��xmȴ��9�m�3.*ec��0'ʇq~b�N秊 ���0�X8���q0�����Y#�F��u�h��c4��������N0��19E'�خ?:��JOy�n��yI#�(ݖލ�G �PZ��:M�W��V��]_��� ��t�H�t�%�h��%��ĔW���}�2��"�B�=�����<���qx��=�)���/P60+�ۃ�x���N��Bʆ5�����L>���)��$?=��W�Z`��{�Vq��û��N����cpG��6s1@�ޑ���dI�
 ߔs�$�o�ǐ������+�QiVl�ҋ?�F�\ZP (կ�� <��0m懘;I��!�G����6�tV�b���ulY{n@�d�8�� z�Qѻ%��8���ca�J_����󿬾�y�~	���%�Z�:,j^���n��m��@�7E��^��di��J�3ߢ�(Oj��s�}k%��F��x�P[Z6������Vo�v-\��m�II�Z`$F{���h���j�f蕪U('g�B�'�qVlK4L@�=���v��a�i��N��; �1AI�Vy��l�u_[Q�2t>NbHHlc��*��VR}��;a�(7��f��yI ;,��{(��aq���&��� �a��m��5æ Q� �4a����-�����ɨ;AF��~��N����0��4��瞼 �H����*��pGqS�6Yc��@��!��#����`6}�lV�u�n���4Y�L�l��n �ydw��~���?4�{gWH���aE�x�M�Qr$ߞ�Q���<,�zq�OWlp$G~$O��>��`��fA5`����Fk�9����LVw@%��=��e���0��v���mo"Y�E���]�����;��ث��p���d�D����+Zݫ�Cv��4 ��9���1��Nt?�,�~�h>��5�A�y���Ѣ��ee�q_1 ��Qq���q��.F -L�8@���S��O������P�z� ��K����%��3v� ԅ$v:dƑ�%��}�w�� �?�(����tޠڃ�$�a��5���U����fɗi���(z:Kx1]�%�5+d(�2|9�\��e]���t���v�5'�"�\��1.��w��,�ߘ��j��g��:�9�.�Y"E�̋Y1�fb�Ί|�,i�����!�v��!M���\2�8�&�
�*l7���9=��®��+��љ�E�V]_�����k�C�O^�y3{�ab�p$�5�"~œ���	��c�}�.(�o;7�F�7<Br���	{Ƿ���i��%���q>����@��mX�?�C��h
��L�����4�������?+��o8̧=ES��z���i��#��(���������"Ht$�����hўr��R��c��|�����op�9A�2�R�(�!�v���a�إUC���&��pm���-����+;�SN�y��n�����i���.#n� ��]��or�J�3@4�X�֝����D%�"�IX��^l�3g8�w܆�5��R���GN	
Z�J���`J���Ͼ�B��)a��ņ�EVG�/�� 9޷���{���X�#q�������{-o��κYH^|��z>�/bF����ȗ�U�H������t�y૚�Z�܉�c(�q�~�k����wk���m'�zj��L��4�O.'�O���5N�޲�Vpvk�w!gvr��t����ʒ@�r�ID�٤�����Z��Y�v�{����'O�t��         �   x�m�9�0Ek�)|,���
� ��	h&�B����=�c���
M��<��v�Pz�.%�Uy
�d:.�����ue�����n�#2q�#�6�|��̀=_w9_�5%�9r���5�l�
�S����v�|e��)L�2~j�P�Q_rj0��c+睉����6���<>�p��{�/�/����+�+ x�#a<         s   x�M�M
�0�ur�����p��u[������)�����������҆HX����}����=�YM���QR� �����`����jhm���f$m5��fwH-��?�,��"�5@     
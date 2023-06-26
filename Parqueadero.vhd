library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Parqueadero is
    port (
        reloj        : in std_logic;
        Front_Sensor : in std_logic;             -- Front Sensor
        Back_Sensor  : in std_logic;             -- Back sensor
        Code         : in std_logic_vector(3 downto 0);    -- Código de acceso
        Red_LED      : out std_logic;             -- LED rojo
        Green_LED    : out std_logic;             -- LED verde
        Segments1    : out std_logic_vector(6 downto 0);   -- Salida para el primer display de 7 segmentos (unidades)
        Segments10   : out std_logic_vector(6 downto 0)    -- Salida para el segundo display de 7 segmentos (decenas)
    );
end entity;

architecture Behavioral of Parqueadero is
    type Estado_Acceso is (Esperando_Ingreso, Verificando_Codigo, Ingreso_Aceptado, Ingreso_Denegado);
    signal estado_acceso1 : Estado_Acceso;

    type Estado_Deteccion is (Esperando_Ingreso2, Verificando_Sensor, Ingreso_Detectado);
    signal estado_deteccion1 : Estado_Deteccion;

    signal intentos : natural range 0 to 3 := 0;
    signal password : std_logic_vector(3 downto 0) := "0001";

    signal cronometro : integer range 0 to 99 := 0;
    signal lugar_asignado : std_logic_vector(2 downto 0) := "000";
     
    signal clock: std_logic;
    signal clock_2: std_logic;
     
    component freq_divider
        port (clk : in std_logic;
              out1, out2 : buffer std_logic);
    end component;

    -- Función para verificar la disponibilidad de un lugar en el parqueadero
    function lugar_disponible(lugar : integer) return boolean is
    begin
        -- Implementa la lógica para verificar la disponibilidad del lugar
        -- Retorna TRUE si el lugar está disponible, FALSE en caso contrario
        -- Puedes implementar tu propia lógica aquí
        return TRUE;
    end function;

    function asignar_lugar return std_logic_vector is
        variable lugar : integer range 0 to 7;
    begin
        for i in 0 to 7 loop
            if lugar_disponible(i) then -- Verificar si el lugar está disponible
                lugar := i;
                exit; -- Salir del bucle al encontrar un lugar disponible
            end if;
        end loop;
        return std_logic_vector(to_unsigned(lugar, 3)); -- Convertir el lugar a std_logic_vector(2 downto 0)
    end function;

begin
    Relog_1_segundo: freq_divider port map (clk => reloj, out1 => clock, out2 => clock_2);

    -- Máquina de estado del Front Sensor
    process (Front_Sensor, Code)
    begin
        case estado_acceso1 is
            when Esperando_Ingreso =>
                if Front_Sensor = '1' then
                    estado_acceso1 <= Verificando_Codigo;
                    intentos <= 0;
                else
                    estado_acceso1 <= Esperando_Ingreso;
                end if;

            when Verificando_Codigo =>
                if Code = password then
                    estado_acceso1 <= Ingreso_Aceptado;
                else
                    if intentos = 2 then
                        estado_acceso1 <= Ingreso_Denegado;
                    else
                        estado_acceso1 <= Verificando_Codigo;
                        intentos <= intentos + 1;
                    end if;
                end if;

            when Ingreso_Aceptado =>
                estado_acceso1 <= Esperando_Ingreso;

            when Ingreso_Denegado =>
                estado_acceso1 <= Esperando_Ingreso;
        end case;
    end process;

    -- Máquina de estado del back sensor
    process (Back_Sensor)
    begin
        case estado_deteccion1 is
            when Esperando_Ingreso2 =>
                if Front_Sensor = '1' then
                    estado_deteccion1 <= Verificando_Sensor;
                else
                    estado_deteccion1 <= Esperando_Ingreso2;
                end if;

            when Verificando_Sensor =>
                if Back_Sensor = '1' then
                    estado_deteccion1 <= Ingreso_Detectado;
                    cronometro <= 0; -- Reiniciar el cronómetro cuando el vehículo ingresa
                    lugar_asignado <= asignar_lugar; -- Asignar un lugar al vehículo
                else
                    estado_deteccion1 <= Verificando_Sensor;
                end if;

            when Ingreso_Detectado =>
                if Back_Sensor = '0' then
                    estado_deteccion1 <= Esperando_Ingreso2;
                else
                    estado_deteccion1 <= Ingreso_Detectado;
                end if;
        end case;
    end process;

    -- Control de los LEDs y displays de 7 segmentos
    process (clock)
    begin
        if clock = '1' then
            if estado_acceso1 = Ingreso_Aceptado then
                Red_LED <= '0';
                Green_LED <= '1';
            elsif estado_acceso1 = Ingreso_Denegado then
                Red_LED <= '1';
                Green_LED <= '0';
            else
                Red_LED <= '0';
                Green_LED <= '0';
            end if;

            Segments1 <= (others => '0'); -- Coloca aquí la lógica para mostrar los segmentos del cronómetro
            Segments10 <= (others => '0');
        end if;
    end process;

end architecture;


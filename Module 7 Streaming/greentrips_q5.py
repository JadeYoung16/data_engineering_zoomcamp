import os 
from pyflink.datastream import StreamExecutionEnvironment
from pyflink.table import EnvironmentSettings, StreamTableEnvironment

def create_events_source_kafka(t_env):
    table_name = "events"
    source_ddl = f"""
        CREATE TABLE {table_name} (
            PULocationID INTEGER,
            lpep_pickup_datetime BIGINT,
            event_timestamp AS TO_TIMESTAMP_LTZ(lpep_pickup_datetime, 3),
            WATERMARK FOR event_timestamp AS event_timestamp - INTERVAL '5' SECOND
        ) WITH (
            'connector' = 'kafka',
            'properties.bootstrap.servers' = 'redpanda:29092',
            'topic' = 'green-trips',
            'scan.startup.mode' = 'earliest-offset',
            'format' = 'json',
            'json.ignore-parse-errors' = 'true'
        )
    """
    t_env.execute_sql(source_ddl)
    return table_name

def create_sessions_sink_postgres(t_env):
    # This must match your Postgres table structure
    sink_ddl = """
        CREATE TABLE sink_sessions (
            window_start TIMESTAMP(3),
            window_end TIMESTAMP(3),
            PULocationID INT,
            num_trips BIGINT,
            PRIMARY KEY (window_start, window_end, PULocationID) NOT ENFORCED
        ) WITH (
            'connector' = 'jdbc',
            'url' = 'jdbc:postgresql://postgres:5432/postgres',
            'table-name' = 'green_trips_sessions',
            'username' = 'postgres',
            'password' = 'postgres',
            'driver' = 'org.postgresql.Driver'
        )
    """
    t_env.execute_sql(sink_ddl)
    return 'sink_sessions'

def window_job():
    env = StreamExecutionEnvironment.get_execution_environment()
    env.set_parallelism(1)

    settings = EnvironmentSettings.new_instance().in_streaming_mode().build()
    t_env = StreamTableEnvironment.create(env, environment_settings=settings)

    # 1. Define Source and Sink
    source_table = create_events_source_kafka(t_env)
    sink_table = create_sessions_sink_postgres(t_env)

    # 2. Execute Session Window Query
    try:
        t_env.execute_sql(f"""
            INSERT INTO {sink_table}
            SELECT
                window_start,
                window_end,
                PULocationID,
                COUNT(*) AS num_trips
            FROM TABLE(
                SESSION(
                    TABLE {source_table} PARTITION BY PULocationID,
                    DESCRIPTOR(event_timestamp), 
                    INTERVAL '5' MINUTES
                )
            )
            GROUP BY window_start, window_end, PULocationID
        """).wait()
    except Exception as e:
        print(f"Flink Job Failed: {str(e)}")

if __name__ == '__main__':
    window_job()
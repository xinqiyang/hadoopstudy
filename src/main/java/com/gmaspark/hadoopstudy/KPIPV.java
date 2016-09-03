package com.gmaspark.hadoopstudy;

/**
 * Created by xinqiyang on 8/28/16.
 */
import java.io.IOException;
import java.util.Iterator;

import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapred.FileInputFormat;
import org.apache.hadoop.mapred.FileOutputFormat;
import org.apache.hadoop.mapred.JobClient;
import org.apache.hadoop.mapred.JobConf;
import org.apache.hadoop.mapred.MapReduceBase;
import org.apache.hadoop.mapred.Mapper;
import org.apache.hadoop.mapred.OutputCollector;
import org.apache.hadoop.mapred.Reducer;
import org.apache.hadoop.mapred.Reporter;
import org.apache.hadoop.mapred.TextInputFormat;
import org.apache.hadoop.mapred.TextOutputFormat;

public class KPIPV {

    public static class KPIPVMapper extends MapReduceBase implements Mapper {
        private IntWritable one = new IntWritable(1);
        private Text word = new Text();


//        public void map(Object key, Text value, OutputCollector output, Reporter reporter) throws IOException {
//            KPI kpi = KPI.filterPVs(value.toString());
//            if (kpi.isValid()) {
//                word.set(kpi.getRequest());
//                output.collect(word, one);
//            }
//        }

        public void map(Object o, Object o2, OutputCollector outputCollector, Reporter reporter) throws IOException {
            KPI kpi = KPI.filterPVs(o2.toString());
            if (kpi.isValid()) {
                word.set(kpi.getRequest());
                outputCollector.collect(word, one);
            }
        }
    }

    public static class KPIPVReducer extends MapReduceBase implements Reducer {
        private IntWritable result = new IntWritable();


//        public void reduce(Text key, Iterator values, OutputCollector output, Reporter reporter) throws IOException {
//            int sum = 0;
//            while (values.hasNext()) {
//                sum += Integer.valueOf(values.next().toString());
//            }
//            result.set(sum);
//            output.collect(key, result);
//        }

        public void reduce(Object o, Iterator iterator, OutputCollector outputCollector, Reporter reporter) throws IOException {
            int sum = 0;
            while (iterator.hasNext()) {
                sum += Integer.valueOf(iterator.next().toString());
            }
            result.set(sum);
            outputCollector.collect(o, result);
        }
    }

    public static void main(String[] args) throws Exception {

        JobConf conf = new JobConf(KPIPV.class);
        conf.setJobName("KPIPV");

        conf.setMapOutputKeyClass(Text.class);
        conf.setMapOutputValueClass(IntWritable.class);

        conf.setOutputKeyClass(Text.class);
        conf.setOutputValueClass(IntWritable.class);

        conf.setMapperClass(KPIPVMapper.class);
        conf.setCombinerClass(KPIPVReducer.class);
        conf.setReducerClass(KPIPVReducer.class);

        conf.setInputFormat(TextInputFormat.class);
        conf.setOutputFormat(TextOutputFormat.class);

        FileInputFormat.setInputPaths(conf, new Path(args[0]));
        FileOutputFormat.setOutputPath(conf, new Path(args[1]));

        JobClient.runJob(conf);
        System.exit(0);
    }
}
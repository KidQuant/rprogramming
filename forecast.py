if __name__ == "__main__":
    # Open the forecast CSV file and read in the lines
    forecasts = open("forecast.csv", "r").readlines()

    # Run through the list and lag the forecast by one
    old_value = 1
    new_list = []
    for f in forecast[1:]:
        strpf = f.replace('"','').strip()
        new_str = "%s,%s\n" % (strpf, old_value)
        newspl = new_str.strip().split(",")
        final_str = "%s,%s\n" % (newspl[0], newspl[2])
        final_str = final_str.replace('"','')
        old_value = f.strip().split(',')[1]
        new_list.append(final_str)

# Output the updated forecasts CSV file
out = open("forecast_new.csv", "w")
for n in new_list:
    out.write(n)
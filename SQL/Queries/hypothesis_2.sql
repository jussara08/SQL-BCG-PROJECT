USE wonka_db;

-- Analysis of Company Sales / Profit by Factory
-- SABINA COMMENT: Really liked the analysis & conclusions overall!
-- ... HOWEVER I don't see any time period mentioned anywhere :eyes: are the millions for this year, last year, 6 months, etc.? This is very important, always think about the period!



-- Total profit & sales by factory:
SELECT
    f.factory_name,
    SUM(s.sales_amount) AS `total_sales ($)`,
    SUM(s.gross_profit) AS `total_profit ($)`,
    SUM(s.units) AS total_units
FROM sales s
JOIN factories f ON s.factory_id = f.factory_id
GROUP BY f.factory_name
ORDER BY `total_profit ($)` DESC;
-- Lot's O'Nuts made more than 3.8 Million dollars selling more then 1 Million units being the top seller 
-- at Wonka Company.
-- Wicked Choccy's with the 2nd place selling almost 775k units, making more than 2.7 Million dollars and 
-- a profit of 1.75 Million.
-- Secret Factory with intermediate but healthy results, making 256k dollars in sales, a profit of 128k
-- with only 28k units sold. 
-- Sugar Shack does not show many units sold, with only 734 single units sold, making only 1490 dollars
-- and a total profit of 823.24 dollars, although this seems negative they're still positive numbers 
-- and suggests higher profit per unit, just not as demanding as the other 3 factories we mentioned before. 
-- The Other Factory has bad results overall, still profitable but can be considered for closure,
-- sitting with more than 10k units sold and a total profit of only 2682 dollars. 
-- The Other Factory results tells us we should focus more on the other factories or restructure the
-- whole factory sales strategy. 


-- Profit margin by factory:
SELECT
    f.factory_name,
    ROUND(
        CASE
            WHEN SUM(s.sales_amount) = 0 THEN 0
            ELSE SUM(s.gross_profit) / SUM(s.sales_amount)
        END,
        2
    ) AS profit_margin
FROM sales s
JOIN factories f ON s.factory_id = f.factory_id
GROUP BY f.factory_name
ORDER BY profit_margin DESC;
-- Nearly 70% of Lot's O'Nuts revenue becomes profit;
    -- This factory is highly cost-efficient and a great candidate for increased production as well as a 
    -- replicator for its operation model elsewhere.
    -- Wicked Choccy's with almost same results (65%) also applies to this insights.
    -- Both have consistent profitability.
    -- Sugar Shack and Secret Factory are both intermediate factories sitting between 50% - 60%.
    -- Both have moderate profitability but both healthy, worth optimizing rather than closing.
    -- The Other Factory with 8% profit margin only.
    -- It's a critical concern to the company, should be audited immediatly and considered for restructuring
    -- or closure.
-- Is revenue concentration happening in one factory?
	-- No, revenue is dissipated through most factories ranging between 50% to 70% which is a healthy range. 
    -- SABINA COMMENT: 50-70% is an incredibly healthy profit, very much impossible to achieve, really, in the CPG (Consumer Packaged Goods) industry. 
    -- This is not something you'd know, of course, but typically a profit of 25-30% would be considered high here. 
    -- Usually it depends on whether these are premium/luxury products (which they're not, based on unit price) but in this case it's probs because it's not real data. 
    -- Actually good for me to know to adjust the dataset in the future.

    -- From the 5 Factories, only one is in negative shape.

-- What type of product sells more at each factory?
SELECT
    f.factory_name,
    p.product_name,
    SUM(s.units) AS total_units_sold
FROM sales s
JOIN factories f ON s.factory_id = f.factory_id
JOIN products p ON s.product_id = p.product_id
GROUP BY f.factory_name, p.product_name
ORDER BY f.factory_name, total_units_sold DESC;
-- Lot’s O’ Nuts and Wicked Choccy’s are the company’s primary production hubs, each selling over 700,000 
-- units across a small number of high-demand Wonka Bar products. This indicates strong economies of scale 
-- and a clear focus on core chocolate offerings.

-- Wonka Bars dominate total unit sales, confirming they are the company’s flagship products and the 
-- main drivers of manufacturing volume. 

-- Secret Factory operates at a significantly smaller scale, producing niche and novelty products such
-- as Wonka Gum and Lickable Wallpaper. While volumes are low, these products may justify their existence 
-- through higher margins or strategic brand value.

-- Sugar Shack produces a wide variety of products but at very low unit volumes. This suggests 
-- small-batch or experimental production, which may support product diversification but does not 
-- significantly contribute to total sales volume.
-- SABINA COMMENT: Good hypothesis - would also consider whether the factory is new or perhaps very far away from the customer base, which you could check in your data!

-- The Other Factory relies almost entirely on a single product (Kazookles), creating a potential 
-- operational risk. Without diversification or improved profitability, this factory may require 
-- restructuring or closure as mentioned before. 
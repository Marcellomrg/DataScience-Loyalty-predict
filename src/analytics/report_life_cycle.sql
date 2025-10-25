SELECT dtRef,
        DescLifeCycle,
        cluster,
        COUNT(*) AS qntCLiente

FROM life_cycle

GROUP BY dtRef,DescLifeCycle,cluster

ORDER BY dtRef,DescLifeCycle,cluster